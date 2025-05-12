{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.aider = {
        basePackage = pkgs.aider-chat-with-playwright;
        flags = [
          "--no-check-update"
          "--gitignore"
          "--no-auto-commit"
        ];
      };
    }
  ];
}
