# lib.util: Utility functions for common Nix operations and system management. {#sec-functions-library-util}
Utility functions for common Nix operations and system management.

This module provides helper functions that simplify common patterns
in Nix flakes, particularly around system architecture handling and
attribute set manipulation.

## `lib.util.forAllSystems` {#function-library-lib.util.forAllSystems}

Apply a function to each supported system and merge the results.

Iterates over a predefined list of system architectures,
applies the given function to each system, and recursively merges all
results into a single attribute set.

### Arguments

- `pkgs`: A nixpkgs package set
- `fn`: Function to apply to each system string

### Type

```
forAllSystems :: pkgs -> (string -> attrs) -> attrs
```

### Example

```nix
forAllSystems pkgs (system: {
  packages.${system}.hello = pkgs.legacyPackages.${system}.hello;
})
=> { packages = { x86_64-linux = { hello = <derivation>; }; aarch64-linux = { hello = <derivation>; }; }; }
```


