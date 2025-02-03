{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.dprint = {
        basePackage = pkgs.dprint;
        flags = [
          "--config"
          ./dprint.json
        ];
      };
    }
  ];
}
