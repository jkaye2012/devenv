{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    wrapper-manager.url = "github:viperML/wrapper-manager";
    nixgl.url = "github:nix-community/nixGL";
    gitpod-cli = {
      url = "https://gitpod.io/static/bin/gitpod-cli-linux-amd64";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrapper-manager,
      nixgl,
      gitpod-cli,
    }:
    let
      lib = (import ./lib.nix);
      name = "devenv";
      parts = lib.forAllSystems nixpkgs (
        system:
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ nixgl.overlay ];
          };
          basePackages = (import ./packages.nix { inherit pkgs; });

          dprint = (import ./dprint { inherit pkgs wrapper-manager; });
          gitpod = (import ./gitpod { inherit pkgs wrapper-manager gitpod-cli; });
          helix = (import ./helix { inherit pkgs wrapper-manager; });
          lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
          zellij = (import ./zellij { inherit pkgs wrapper-manager; });

          packages = [
            dprint
            gitpod
            helix
            lazygit
            zellij
          ] ++ basePackages;
        in
        {
          devShells.${system}.default = pkgs.mkShell {
            inherit name packages;
            shellHook = nixpkgs.lib.strings.concatStrings (
              nixpkgs.lib.mapAttrsToList (name: value: "alias ${name}=\"${value}\"\n") lib.bashAliases
            );
          };

          packages.${system} = {
            inherit
              dprint
              gitpod
              helix
              lazygit
              zellij
              ;
            default = pkgs.buildEnv {
              inherit name;
              paths = packages;
            };
          };
        }
      );
    in
    {
      inherit lib;
      inherit (parts) devShells packages;
    };
}
