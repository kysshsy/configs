{ config, dms, pkgs, ... }:

let
  dmsPackage = dms.packages.${pkgs.system}.dms-shell.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      tray_qml="$out/share/quickshell/dms/Modules/DankBar/Widgets/SystemTrayBar.qml"
      chmod u+w "$tray_qml"
      awk '
        /function trayIconSourceFor/ { in_tray = 1 }
        /function activateInlineTrayItem/ { in_tray = 0 }
        in_tray && index($0, "if (icon.startsWith") && index($0, "file://") { resolve = 1 }
        in_tray && resolve && index($0, "return icon;") {
          sub("return icon;", "return Paths.resolveIconUrl(icon);")
          resolve = 0
        }
        { print }
      ' "$tray_qml" > "$TMPDIR/SystemTrayBar.qml"
      cp "$TMPDIR/SystemTrayBar.qml" "$tray_qml"
    '';
  });

in
{
  programs.dank-material-shell = {
    enable = true;
    package = dmsPackage;
    systemd.enable = true;
    enableAudioWavelength = false;
    enableCalendarEvents = false;
    enableDynamicTheming = false;
  };

  home.packages = [ pkgs.adwaita-icon-theme ];

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
