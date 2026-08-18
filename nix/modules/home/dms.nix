{ config, ... }:

{
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableAudioWavelength = false;
    enableCalendarEvents = false;
    enableDynamicTheming = false;
  };

  xdg.configFile."DankMaterialShell" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/nix/data/dms/config";
    force = true;
  };

  home.file.".local/state/DankMaterialShell" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/nix/data/dms/state";
    force = true;
  };
}
