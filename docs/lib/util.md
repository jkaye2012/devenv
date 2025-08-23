# lib.util: Utility functions for common Nix operations and system management {#sec-functions-library-util}
Utility functions for common Nix operations and system management

This module provides helper functions that simplify common patterns
in Nix flakes, particularly around system architecture handling and
attribute set manipulation.

## `lib.util.forAllSystems` {#lib.util.forAllSystems}

Apply a function to each supported system and merge the results.

Iterates over a predefined list of system architectures,
applies the given function to each system, and recursively merges all
results into a single attribute set.

### Type

```
forAllSystems :: pkgs -> (string -> attrs) -> attrs
```

### Arguments

pkgs
: A nixpkgs package set

fn
: Function to apply to each system string

### Example

```nix
forAllSystems pkgs (system: {
  packages.${system}.hello = pkgs.legacyPackages.${system}.hello;
})
=> { packages = { x86_64-linux = { hello = <derivation>; }; aarch64-linux = { hello = <derivation>; }; }; }
```

## `lib.util.generateNixDocs` {#lib.util.generateNixDocs}

Generate nixdoc markdown documentation for all .nix files in a directory.

Creates a shell script that recursively finds all .nix files in the specified
source directory and generates markdown documentation using nixdoc. The output
files maintain the same directory structure in the documentation folder.

### Type

```
generateNixDocs :: pkgs -> Derivation
```

### Arguments

pkgs
: A nixpkgs package set

### Example

```nix
let
  docScript = generateNixDocs pkgs;
in
  pkgs.mkShell {
    packages = [ docScript ];
  }
# Then run: generate-docs.sh
```


