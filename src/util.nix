{
  /**
      Apply a function to each supported system and merge the results.

      Iterates over a predefined list of system architectures,
      applies the given function to each system, and recursively merges all
      results into a single attribute set.

      # Arguments

      - `pkgs`: A nixpkgs package set
      - `fn`: Function to apply to each system string

      # Type

      ```
      forAllSystems :: pkgs -> (string -> attrs) -> attrs
      ```

      # Example

      ```nix
      forAllSystems pkgs (system: {
        packages.${system}.hello = pkgs.legacyPackages.${system}.hello;
      })
      => { packages = { x86_64-linux = { hello = <derivation>; }; aarch64-linux = { hello = <derivation>; }; }; }
      ```
  */
  forAllSystems =
    pkgs: fn:
    builtins.foldl' pkgs.lib.recursiveUpdate { } (
      pkgs.lib.forEach [
        "x86_64-linux"
        "aarch64-linux"
      ] fn
    );
}
