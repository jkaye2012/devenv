{ pkgs, wrapper-manager }:

let
  zellij-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.helix = {
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
