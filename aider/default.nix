{ pkgs, wrapper-manager }:

let
  aider-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.aider = {
          basePackage = pkgs.aider-chat-with-playwright;
          prependFlags = [
            "--no-check-update"
            "--gitignore"
            "--no-auto-commit"
          ];
        };
      }
    ];
  };
in
aider-eval.config.build.toplevel
