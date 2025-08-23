/**
    Utility functions for common Nix operations and system management

    This module provides helper functions that simplify common patterns
    in Nix flakes, particularly around system architecture handling and
    attribute set manipulation.
*/
{
  /**
      Apply a function to each supported system and merge the results.

      Iterates over a predefined list of system architectures,
      applies the given function to each system, and recursively merges all
      results into a single attribute set.

      # Type

      ```
      forAllSystems :: pkgs -> (string -> attrs) -> attrs
      ```

      # Arguments

      pkgs
      : A nixpkgs package set

      fn
      : Function to apply to each system string

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

  /**
      Generate nixdoc markdown documentation for all .nix files in a directory.

      Creates a shell script that recursively finds all .nix files in the specified
      source directory and generates markdown documentation using nixdoc. The output
      files maintain the same directory structure in the documentation folder.

      # Type

      ```
      generateNixDocs :: pkgs -> Derivation
      ```

      # Arguments

      pkgs
      : A nixpkgs package set

      # Example

      ```nix
      let
        docScript = generateNixDocs pkgs;
      in
        pkgs.mkShell {
          packages = [ docScript ];
        }
      # Then run: generate-docs.sh
      ```
  */
  generateNixDocs =
    pkgs:
    pkgs.writeScriptBin "generate-docs.sh" ''
      #!/usr/bin/env bash

      set -euo pipefail

      SRC_DIR="nix"
      DOCS_DIR="docs/lib"

      mkdir -p "$DOCS_DIR"

      find "$SRC_DIR" -name "*.nix" -type f | while read -r nix_file; do
          rel_path="''${nix_file#"$SRC_DIR/"}"

          category_path="''${rel_path%.nix}"
          category_name=$(basename "$category_path")

          output_dir="$DOCS_DIR/$(dirname "$category_path")"
          mkdir -p "$output_dir"

          output_file="$DOCS_DIR/''${category_path}.md"
          echo "Generating documentation for $nix_file -> $output_file"

          ${pkgs.nixdoc}/bin/nixdoc \
              --file "$nix_file" \
              --category "$category_name" \
              --description "lib.$category_name: $(head -2 "$nix_file" | tail -1 | xargs)" \
              --anchor-prefix "" \
              > "$output_file"
      done

      echo "Documentation generation complete!"
    '';
}
