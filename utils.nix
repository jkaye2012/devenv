{
  forAllSystems =
    pkgs: fn:
    pkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ] (system: fn pkgs.legacyPackages.${system});
}
