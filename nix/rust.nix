/**
    Functions to simplify building and packaging of Rust code for common configurations.

    These functions carry a dependency on [crane](https://crane.dev/index.html). I have found
    This to be the most flexible library for building Rust projects with more advanced types
    of customization.

    I generally prefer to use [fenix](https://github.com/nix-community/fenix) for my toolchains, though this is not required. Any
    crane-compatible toolchain should suffice.

    Most commonly, these functions will be used at the top level of a flake responsible for building a Cargo project:

    ```nix
  {
    inputs = {
      nixpkgs.url = "nixpkgs/nixos-unstable";
      fenix = {
        url = "github:nix-community/fenix/monthly";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      devenv = {
        url = "github:jkaye2012/devenv";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      crane.url = "github:ipetkov/crane";
    };

    outputs =
      {
        self,
        fenix,
        nixpkgs,
        devenv,
        crane,
      }:
      devenv.lib.util.forAllSystems nixpkgs (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          fenix' = fenix.packages.${system};
          crane' = (crane.mkLib pkgs).overrideToolchain fenix'.complete.toolchain;
          crane-stable = (crane.mkLib pkgs).overrideToolchain fenix'.stable.minimalToolchain;
          manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
          src = crane'.cleanCargoSource ./.;

          project = devenv.lib.rust.createProject {
            inherit src crane-stable;

            name = "example";
            crane = crane';
            no-std = true;
            examples = [ "examples/basic" ];
            features = [ "serde" ];
          };
        in
        {
          devShells.${system}.default = pkgs.mkShell {
            inherit (manifest) name;

            inputsFrom = [ devenv.devShells.${system}.default ];

            packages = with pkgs; [
              cargo-show-asm
              fenix'.complete.toolchain
              linuxPackages_latest.perf
              lldb
            ];

            RUSTDOCFLAGS = "--cfg docsrs";
          };

          checks.${system} = project.checks;
          packages.${system} = project.packages;
        }
      );
  }  ```
*/
rec {
  /**
    Build a Rust package from a subdirectory using crane.
    This is meant for building individual examples within the context of the
    "containing" crate specified by `src`.

    # Example

    ```nix
    let
      crane' = crane.mkLib nixpkgs;
    in
      buildExample {
        src = crane'.cleanCargoSource ./.;
        crane = crane';
        subdir = "examples/my-app";
        args = {
          buildInputs = [ pkg-config ];
        };
      }
    ```

    # Type

    ```
    buildExample :: {
      src :: Path,
      crane :: Derivation,
      subdir :: PathString,
      args? :: AttrSet
    } -> Derivation
    ```

    # Arguments

    src
    : The directory to be built (usually, the root of a Rust project)

    crane
    : Crane instance for building core project artifacts

    subdir
    : Relative path to the subdirectory containing the example project

    args
    : Additional arguments to pass to crane.buildPackage (optional, default: `{ }`)
  */
  buildExample =
    {
      src,
      crane,
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

  /**
    Build and test the `src` package with a specific feature enabled.

    # Example

    ```nix
    let
      crane' = crane.mkLib nixpkgs;
    in
      testFeature {
        src = crane'.cleanCargoSource ./.;
        crane = crane';
        feature = "async-tokio";
        args = {
          buildInputs = [ openssl ];
        };
      }
    ```

    # Type

    ```
    testFeature :: {
      src :: Path,
      crane :: Derivation,
      feature :: String,
      args? :: AttrSet
    } -> Derivation
    ```

    # Arguments

    src
    : The directory to be built (usually, the root of a Rust project)

    crane
    : Crane instance for building core project artifacts

    feature
    : Name of the Cargo feature to enable for testing

    args
    : Additional arguments to pass to crane.buildPackage (optional, default: `{ }`)
  */
  testFeature =
    {
      src,
      crane,
      feature,
      args ? { },
    }:
    crane.buildPackage {
      inherit src;
      cargoTestExtraArgs = "--no-default-features --all-targets --features ${feature}";
    }
    // args;

  /**
    Create a Rust project with checks and packages for various build configurations.
    The attributes of the returned AttrSet can be used directly as flake outputs.

    # Example

    ```nix
    # Assumes that `crane` and `fenix` are flake inputs; note that any toolchain could be used,
    # there is no inherent or implicit dependency on Fenix
    let
      crane' = crane.mkLib nixpkgs;
      crane-stable = (crane.mkLib pkgs).overrideToolchain fenix'.stable.minimalToolchain
    in
      createProject {
        inherit crane-stable;

        src = crane'.cleanCargoSource ./.;
        crane = crane';
        name = "my-crate";
        no-std = true;
        examples = [ "examples/basic" "examples/advanced" ];
        features = [ "async" "serde" ];
      }
    ```

    # Type

    ```
    createProject :: {
      name :: String,
      src :: RelativePath,
      crane :: Derivation,
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

    src
    : The directory to be built (usually, the root of a Rust project)

    crane
    : Crane instance for building core project artifacts

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
      src,
      crane,
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
      base = [
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
      ++ nostd;
      examples' = map (ex: {
        name = name + "-" + sanitize ex;
        value = buildExample {
          subdir = ex;
          args = {
            cargoArtifacts = main;
          };
        };
      }) examples;
      features' = map (f: {
        name = name + "-test-" + f;
        values = testFeature f;
      }) features;
    in
    {
      checks = builtins.listToAttrs (base ++ examples' ++ features');
      packages = builtins.listToAttrs (base ++ examples');
    };
}
