{ crane, src, ... }:
{
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
}
