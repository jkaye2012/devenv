{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.helix = {
        basePackage = pkgs.lazygit;
        flags = [
          "--use-config-file"
          ./config.yml
        ];
      };
    }
  ];
}
