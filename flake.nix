{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    wrapper-manager.url = "github:viperML/wrapper-manager";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
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
          just = pkgs.just;
          lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
          yazi = pkgs.yazi;
          zellij = (
            import ./zellij {
              inherit wrapper-manager;
              pkgs = pkgs-unstable;
            }
          );

          packages = [
            aider
            dprint
            glab
            helix
            just
            lazygit
            yazi
            zellij
          ] ++ basePackages;
        in
        {
          devShells.${system}.default = pkgs.mkShell {
            inherit name packages;

            EDITOR = "hx";

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
