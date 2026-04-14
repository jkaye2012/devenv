{ pkgs, wrapper-manager }:

let
  zellij-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.zellij = {
          basePackage = pkgs.zellij;
          prependFlags = [
            "--config"
            ./config.kdl
            "--layout"
            ./layout.kdl
          ];
        };
      }
    ];
  };
in
zellij-eval.config.build.toplevel
