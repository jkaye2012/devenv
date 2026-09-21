{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    wrapper-manager.url = "git+https://codeberg.org/viperML/wrapper-manager";
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      wrapper-manager,
      haumea,
      agent-sandbox,
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
            config.allowUnfree = true;
          };
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          basePackages = (import ./packages.nix { inherit pkgs pkgs-unstable; });
          sbx = agent-sandbox.lib.${system};

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
          pi-sandboxed = sbx.mkSandbox {
            pkg = pkgs-unstable.pi-coding-agent;
            binName = "pi";
            outName = "pi";
            allowedPackages =
              sbx.commonTools
              ++ (with pkgs; [
                rustc
                cargo
                clippy
                rustfmt
                clang
              ]);
            rwDirs = [ "$HOME/.pi" ];
            rwFiles = [ ];
            roFiles = [ "$HOME/.config/git/config" ];
            env = {
              ZAI_API_KEY = "$ZAI_API_KEY";
            };
            # allowedDomains = {
            #   "generativelanguage.googleapis.com" = "*";
            #   "api.zai.com" = "*";
            #   "registry.npmjs.org" = [
            #     "GET"
            #     "HEAD"
            #   ];
            #   "raw.githubusercontent.com" = [
            #     "GET"
            #     "HEAD"
            #   ];
            #   "api.github.com" = [
            #     "GET"
            #     "HEAD"
            #   ];
            # };
          };
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
            pi-sandboxed
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
