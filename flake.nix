{
  description = "A super-powered development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
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
      lib = (import ./utils.nix);
      name = "devenv";
      parts = lib.forAllSystems nixpkgs (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          helix = (import ./helix { inherit pkgs wrapper-manager; });
          lazygit = (import ./lazygit { inherit pkgs wrapper-manager; });
          zellij = (import ./zellij { inherit pkgs wrapper-manager; });
          packages = with pkgs; [
            helix
            lazygit
            zellij
            tree
          ];
        in
        {
          devShells.${system}.default = pkgs.mkShell {
            inherit name packages;
            shellHook = builtins.readFile ./shell-customization.sh;
          };

          packages.${system} = {
            inherit helix lazygit zellij;
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
