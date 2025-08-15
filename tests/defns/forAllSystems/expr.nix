{ pkgs, devenv }:

devenv.util.forAllSystems pkgs (
  s:
  builtins.listToAttrs [
    {
      name = s;
      value = s;
    }
  ]
)
