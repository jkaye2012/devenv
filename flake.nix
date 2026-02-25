{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    wrapper-manager.url = "github:viperML/wrapper-manager";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      wrapper-manager,
      nixgl,
      haumea,
      pre-commit-hooks,
    }:
    let
      lib = haumea.lib.load {
        src = ./nix;
        inputs = {
          inherit (nixpkgs) lib;
        };
      };
      name = "devenv";
      parts = lib.util.forAllSystems nixpkgs (
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
          llm = (
            import ./llm {
              inherit wrapper-manager;
              pkgs = pkgs-unstable;
            }
          );
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
            llm
            zellij
          ]
          ++ basePackages;
        in
        {
          checks.${system} =
            let
              gen-docs = self.lib.util.generateNixDocs pkgs;
            in
            {
              pre-commit-check = pre-commit-hooks.lib.${system}.run {
                src = ./.;
                hooks = {
                  generate-docs = {
                    enable = true;
                    name = "Generate docs";
                    entry = "${gen-docs}/bin/generate-docs.sh";
                    files = "^nix/.*\.nix";
                  };
                };
              };
            };

          devShells.${system} = rec {
            basic = pkgs.mkShell {
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

            full = pkgs.mkShell {
              inputsFrom = [ basic ];
              shellHook = self.checks.${system}.pre-commit-check.shellHook;
              buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            };

            default = basic;
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
      inherit (parts) devShells packages checks;
    };
}
