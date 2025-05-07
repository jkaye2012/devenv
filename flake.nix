{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    wrapper-manager.url = "github:viperML/wrapper-manager";
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      wrapper-manager,
      nixgl,
    }:
    let
      lib = (import ./lib.nix);
      name = "devenv";
      parts = lib.forAllSystems nixpkgs (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nixgl.overlay ];
          };
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
          };
          basePackages = (import ./packages.nix { inherit pkgs; });

          aider = (
            import ./aider {
              inherit wrapper-manager;
              pkgs = pkgs-unstable;
            }
          );
          dprint = (import ./dprint { inherit pkgs wrapper-manager; });
          glab = pkgs.glab;
          helix = (import ./helix { inherit pkgs wrapper-manager; });
          lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
          zellij = (import ./zellij { inherit pkgs wrapper-manager; });

          packages = [
            aider
            dprint
            glab
            helix
            lazygit
            zellij
          ] ++ basePackages;
        in
        {
          devShells.${system}.default = pkgs.mkShell {
            inherit name packages;

            shellHook =
              let
                aliases = nixpkgs.lib.strings.concatStrings (
                  nixpkgs.lib.mapAttrsToList (name: value: "alias ${name}=\"${value}\"\n") lib.bashAliases
                );
                customizations = builtins.readFile ./shell-customization.sh;
              in
              ''
                ${customizations}

                ${aliases}
              '';
          };

          packages.${system} = {
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
