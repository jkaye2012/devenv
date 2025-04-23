{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.aider = {
        basePackage = pkgs.aider-chat;
        flags = [
          "--no-check-update"
          "--gitignore"
        ];
      };
    }
  ];
}
