{ pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];
  xdg.configFile."nvim".source = ../../../editor/.config/nvim;
}
