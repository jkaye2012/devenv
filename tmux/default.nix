{ pkgs, wrapper-manager }:

wrapper-manager.lib.build {
  inherit pkgs;
  modules = [
    {
      wrappers.helix = {
        basePackage = pkgs.tmux;
        flags = [
          "-f"
          ./tmux.conf
        ];
        pathAdd = with pkgs.tmuxPlugins; [
          continuum
          resurrect
        ];
      };
    }
  ];
}
