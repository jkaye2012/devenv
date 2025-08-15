{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    call-flake.url = "github:divnix/call-flake";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    namaka = {
      url = "github:nix-community/namaka/v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      call-flake,
      flake-parts,
      namaka,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.checks = namaka.lib.load {
        src = ./defns;
        inputs = {
          pkgs = nixpkgs;
          devenv = (call-flake ../.).lib;
        };
      };

      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem =
        { inputs', pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              inputs'.namaka.packages.default
            ];
          };
        };
    };
}
