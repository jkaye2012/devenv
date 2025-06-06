{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.helix = {
        basePackage = pkgs.helix;
        flags = [
          "--config"
          ./config.toml
        ];
        pathAdd = with pkgs; [
          helix-gpt
          marksman
          nil
          nixfmt-rfc-style
        ];
      };
    }
  ];
}
