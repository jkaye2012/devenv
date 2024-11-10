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
      simple-packages = pkgs: with pkgs; [ tree ];
    in
    {
      devShells = utils.forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inherit name;
          packages = [
            (import ./helix { inherit pkgs wrapper-manager; })
            (import ./lazygit { inherit pkgs wrapper-manager; })
            (import ./zellij { inherit pkgs wrapper-manager; })
          ] ++ (simple-packages pkgs);
          shellHook = builtins.readFile ./shell-customization.sh;
        };
      });

      packages = utils.forAllSystems (pkgs: rec {
        helix = (import ./helix { inherit pkgs wrapper-manager; });
        lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
        zellij = (import ./zellij { inherit pkgs wrapper-manager; });

        default = pkgs.buildEnv {
          inherit name;
          paths = [
            helix
            lazygit
            zellij
          ] ++ (simple-packages pkgs);
        };
      });
    };
}
