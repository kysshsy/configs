{ pkgs, ... }:

{
  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".source =
    ../../../terminal/.config/wezterm/wezterm.lua;
}
