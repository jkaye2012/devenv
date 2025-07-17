{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
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
            config.allowUnfree = true;
          };
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          basePackages = (import ./packages.nix { inherit pkgs pkgs-unstable; });

          aider = (
            import ./aider {
              inherit wrapper-manager;
              pkgs = pkgs-unstable;
            }
          );
          dprint = (import ./dprint { inherit pkgs wrapper-manager; });
          helix = (import ./helix { inherit pkgs wrapper-manager; });
          lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
          zellij = (
            import ./zellij {
              inherit wrapper-manager;
              pkgs = pkgs-unstable;
            }
          );

          packages = [
            aider
            dprint
            helix
            lazygit
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
