{
  pkgs,
  gitpod-cli,
  wrapper-manager,
}:

let
  gitpod = pkgs.stdenv.mkDerivation {
    name = "gitpod";
    src = gitpod-cli;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/gitpod
      chmod +x $out/bin/gitpod
    '';

  };
in

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.gitpod = {
        basePackage = gitpod;
        flags = [
          "--config"
          ./config.yaml
        ];
      };
    }
  ];
}
