{ ... }:

{
  xdg.configFile = {
    "niri/config.kdl".source = ../../data/niri/config.kdl;
    "niri/niri-shortcuts.kdl".source = ../../data/niri/shortcuts.kdl;
    "niri/focus-or-launch" = {
      source = ../../data/niri/focus-or-launch;
      executable = true;
    };
  };
}
