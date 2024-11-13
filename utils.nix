{
  forAllSystems =
    pkgs: fn:
    builtins.foldl' pkgs.lib.recursiveUpdate { } (
      pkgs.lib.forEach [
        "x86_64-linux"
        "aarch64-linux"
      ] fn
    );
}
