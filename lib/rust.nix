{ crane, src, ... }:
rec {
  /*
    Build an Rust package from a subdirectory using crane.
    This is meant for building individual examples within the context of the
    "containing" crate specified by `src`.

    # Example

    ```nix
    buildExample {
      subdir = "examples/my-app";
      args = {
        buildInputs = [ pkg-config ];
      };
    }
    ```

    # Type

    ```
    buildExample :: {
      subdir :: RelativePath,
      args? :: AttrSet
    } -> Derivation
    ```

    # Arguments

    subdir
    : Path to the subdirectory containing the example project

    args
    : Additional arguments to pass to crane.buildPackage (optional, default: `{ }`)
  */
  buildExample =
    {
      subdir,
      args ? { },
    }:
    crane.buildPackage {
      inherit src;
      cargoLock = ./${subdir}/Cargo.lock;
      cargoToml = ./${subdir}/Cargo.toml;

      postUnpack = ''
        cd $sourceRoot/${subdir}
        sourceRoot="."
      '';
    }
    // args;

  /*
    Build and test the `src` package with a specific feature enabled.

    # Example

    ```nix
    testFeature {
      feature = "async-tokio";
      args = {
        buildInputs = [ openssl ];
      };
    }
    ```

    # Type

    ```
    testFeature :: {
      feature :: String,
      args? :: AttrSet
    } -> Derivation
    ```

    # Arguments

    feature
    : Name of the Cargo feature to enable for testing

    args
    : Additional arguments to pass to crane.buildPackage (optional, default: `{ }`)
  */
  testFeature =
    {
      feature,
      args ? { },
    }:
    crane.buildPackage {
      inherit src;
      cargoTestExtraArgs = "--no-default-features --all-targets --features ${feature}";
    }
    // args;

  # My current thought is to test everything using nix flake check; it will be interesting
  # to see how this idea could potentially interact with namaka/humea, as I'm interested in
  # the potential for those ideas as well. Especially humea could be integrated without changing
  # much else here, and would potentially improve the structure and maintainability of this flake
  # greatly, as well as giving me yet another thing to write about.

  /*
    Create a Rust project with checks and packages for various build configurations.
    The attributes of the returned AttrSet can be used directly as flake outputs.

    # Example

    ```nix
    createProject {
      name = "my-crate";
      crane-stable = craneLib.stable;
      no-std = true;
      examples = [ "examples/basic" "examples/advanced" ];
      features = [ "async" "serde" ];
    }
    ```

    # Type

    ```
    createProject :: {
      name :: String,
      crane-stable? :: Derivation,
      no-std? :: Bool,
      examples? :: [ RelativePath ],
      features? :: [ String ]
    } -> {
      checks :: AttrSet,
      packages :: AttrSet
    }
    ```

    # Arguments

    name
    : Base name for the project and its derivations

    crane-stable
    : Stable crane instance for building with stable Rust toolchain (optional, default: `null`)

    no-std
    : Whether to include a no-std build configuration (optional, default: `false`)

    examples
    : List of paths to example subdirectories to build (optional, default: `[ ]`)

    features
    : List of Cargo features to test individually (optional, default: `[ ]`)
  */
  createProject =
    {
      name,
      crane-stable ? null,
      no-std ? false,
      examples ? [ ],
      features ? [ ],
    }:
    let
      sanitize = (ex: builtins.replaceStrings [ "/" ] [ "-" ] ex);
      main = crane.buildPackage {
        inherit src;
        cargoTestExtraArgs = "--all-features";
      };
      stable =
        if crane-stable != null then
          [
            {
              name = name + "-stable";
              value = crane-stable.buildPackage {
                inherit src;
                cargoTestExtraArgs = "--lib";
              };
            }
          ]
        else
          [ ];
      nostd =
        if no-std then
          [
            {
              name = name + "-no-std";
              value = crane.buildPackage {
                inherit src;
                cargoTestExtraArgs = "--no-default-features --all-targets";
              };
            }
          ]
        else
          [ ];
      base = builtins.listToAttrs (
        [
          {
            inherit name;
            value = main;
          }
          {
            name = name + "-doc";
            value = crane.cargoDoc {
              inherit src;
              cargoArtifacts = main;
              cargoDocExtraArgs = "--all-features";
            };
          }
        ]
        ++ stable
        ++ nostd
      );
      examples = map (ex: {
        name = name + "-" + sanitize ex;
        value = buildExample {
          subdir = ex;
          args = {
            cargoArtifacts = main;
          };
        };
      }) examples;
      features = map (f: {
        name = name + "-test-" + f;
        values = testFeature f;
      }) features;
    in
    {
      checks = builtins.listToAttrs (base ++ examples ++ features);
      packages = builtins.listToAttrs (base ++ examples);
    };
}
