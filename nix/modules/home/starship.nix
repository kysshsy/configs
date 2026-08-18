{ pkgs, ... }:

{
  home.packages = [ pkgs.starship ];
  xdg.configFile."starship.toml".source = ../../../shell/.config/starship.toml;
}
