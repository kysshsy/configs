{ lib, pkgs, ... }:

{
  # macOS installs the GUI bundle as a Homebrew cask so Launch Services can
  # expose it in /Applications. Linux keeps the Nix package for the same CLI.
  home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.wezterm ];

  xdg.configFile."wezterm/wezterm.lua".source =
    ../../../terminal/.config/wezterm/wezterm.lua;
}
