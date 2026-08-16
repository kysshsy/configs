{ config, pkgs, ... }:

{
  home.username = "kyss";
  home.homeDirectory = "/home/kyss";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    fuzzel
    neovim
    starship
    tmux
    waybar
    wezterm
    zellij
  ];

  # Node.js itself is immutable in the Nix store. npm therefore installs Codex
  # under the user's home directory instead of attempting to mutate Nix files.
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-packages";
  home.sessionPath = [ "${config.home.homeDirectory}/.npm-packages/bin" ];
  programs.bash.enable = true;

  # These files are portable user-level preferences. Fish is excluded because
  # its current config contains Arch, proxy, Conda, and machine-specific paths.
  xdg.configFile = {
    "git/config".source = ../../shell/.config/git/config;
    "nvim".source = ../../editor/.config/nvim;
    "starship.toml".source = ../../shell/.config/starship.toml;
    "niri/config.kdl".source = ./niri.kdl;
    "wezterm/wezterm.lua".source = ../../terminal/.config/wezterm/wezterm.lua;
    "zellij/config.kdl".source = ../../terminal/.config/zellij/config.kdl;
  };

  home.file.".tmux.conf".source = ../../shell/.tmux.conf;
  programs.home-manager.enable = true;
}
