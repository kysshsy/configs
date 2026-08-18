{ config, pkgs, ... }:

{
  home.packages = [ pkgs.clash-verge-rev pkgs.mihomo ];

  systemd.user.services.mihomo = {
    Unit = {
      Description = "Mihomo proxy core";
      ConditionPathExists = "%h/.config/mihomo/config.yaml";
    };
    Service = {
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d %h/.config/mihomo";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
