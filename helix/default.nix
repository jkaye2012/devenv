{ pkgs, wrapper-manager }:

let
  helix-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.helix = {
          basePackage = pkgs.helix;
          prependFlags = [
            "--config"
            ./config.toml
          ];
          pathAdd = with pkgs; [
            marksman
            nil
            nixfmt-rfc-style
          ];
        };
      }
    ];
  };
in
helix-eval.config.build.toplevel
