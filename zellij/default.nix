{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.helix = {
        basePackage = pkgs.zellij;
        flags = [
          "--config"
          ./config.kdl
          "--layout"
          ./layout.kdl
        ];
      };
    }
  ];
}
