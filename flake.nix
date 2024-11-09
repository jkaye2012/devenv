{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrapper-manager,
    }:
    let
      utils = (import ./utils.nix { pkgs = nixpkgs; });
      name = "devenv";
    in
    {
      devShells = utils.forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inherit name;
          packages = [
            (import ./helix { inherit pkgs wrapper-manager; })
            (import ./lazygit { inherit pkgs wrapper-manager; })
            (import ./tmux { inherit pkgs wrapper-manager; })
            (import ./zellij { inherit pkgs wrapper-manager; })
          ];
        };
      });

      packages = utils.forAllSystems (pkgs: rec {
        helix = (import ./helix { inherit pkgs wrapper-manager; });
        lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
        tmux = (import ./tmux { inherit pkgs wrapper-manager; });
        zellij = (import ./zellij { inherit pkgs wrapper-manager; });

        default = pkgs.buildEnv {
          inherit name;
          paths = [
            helix
            lazygit
            tmux
            zellij
          ];
        };
      });
    };
}
