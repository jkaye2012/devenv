{ pkgs, wrapper-manager }:

let
  lazygit-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.helix = {
          basePackage = pkgs.lazygit;
          prependFlags = [
            "--use-config-file"
            ./config.yml
          ];
        };
      }
    ];
  };
in
lazygit-eval.config.build.toplevel
