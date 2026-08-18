{ pkgs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    gnome-calculator
    vscode
  ];
}
