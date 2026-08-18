{ config, pkgs, ... }:

{
  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    Name=Default
    Default Layout=us
    DefaultIM=rime

    [Groups/0/Items/0]
    Name=keyboard-us
    Layout=

    [Groups/0/Items/1]
    Name=rime
    Layout=

    [GroupOrder]
    0=Default
  '';

  xdg.configFile."fcitx5/conf/global.conf".text = ''
    [Behavior]
    ShareInputState=No
    ResetStateWhenFocusIn=No
  '';

  xdg.dataFile = {
    "icons/hicolor/scalable/apps/fcitx-rime.svg".source =
      "${pkgs.fcitx5-rime}/share/icons/hicolor/scalable/apps/org.fcitx.Fcitx5.fcitx-rime.svg";
    "fcitx5/rime/default.custom.yaml".source =
      ../../data/rime/default.custom.yaml;
    "fcitx5/rime/double_pinyin_flypy.custom.yaml".text = ''
      patch:
        "switches/@2/reset": 0
    '';
  };
}
