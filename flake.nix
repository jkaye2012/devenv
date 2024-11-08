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
    in
    {
      devShells = utils.forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "devenv";
          packages = [ (import ./helix { inherit pkgs wrapper-manager; }) ];
        };
      });

      packages = utils.forAllSystems (pkgs: {
        default = (import ./helix { inherit pkgs wrapper-manager; });
      });
    };
}
