{ pkgs, wrapper-manager }:

let
  dprint-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.dprint = {
          basePackage = pkgs.dprint;
          prependFlags = [
            "--config"
            ./dprint.json
          ];
        };
      }
    ];
  };
in
dprint-eval.config.build.toplevel
