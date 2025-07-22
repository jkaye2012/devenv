{ pkgs, wrapper-manager }:

let
  llm-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = [
      {
        wrappers.llm = {
          basePackage = pkgs.python313Packages.llm;
          prependFlags = [
            "-m"
            "anthropic/claude-3-7-sonnet-latest"
          ];
        };
      }
    ];
  };
in
llm-eval.config.build.toplevel
