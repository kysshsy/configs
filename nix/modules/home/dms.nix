{ config, dms, lib, pkgs, ... }:

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

  # DMS writes settings and state while it is running. Keep those runtime files
  # writable in the XDG directory, but let Home Manager deploy the static
  # plugins themselves.
  xdg.configFile = {
    "DankMaterialShell/plugins/Calculator" = {
      source = ../../data/dms/config/plugins/Calculator;
      force = true;
    };
    "DankMaterialShell/plugins/WebSearch" = {
      source = ../../data/dms/config/plugins/WebSearch;
      force = true;
    };
  };

  home.activation.seedDmsRuntimeConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    dms_config_dir="${config.xdg.configHome}/DankMaterialShell"
    dms_state_dir="${config.home.homeDirectory}/.local/state/DankMaterialShell"

    install -d -m 700 "$dms_config_dir"
    install -d -m 700 "$dms_state_dir"

    if [ ! -e "$dms_config_dir/settings.json" ]; then
      install -Dm644 ${../../data/dms/config/settings.json} "$dms_config_dir/settings.json"
    fi

    if [ ! -e "$dms_config_dir/plugin_settings.json" ]; then
      install -Dm644 ${../../data/dms/config/plugin_settings.json} "$dms_config_dir/plugin_settings.json"
    fi
  '';
}
