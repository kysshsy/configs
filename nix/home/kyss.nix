{ ... }:

{
  home.username = "kyss";
  home.homeDirectory = "/home/kyss";
  home.stateVersion = "26.05";

  imports = [
    ../modules/home/cli-tools.nix
    ../modules/home/gui-apps.nix
    ../modules/home/nodejs.nix
    ../modules/home/fish.nix
    ../modules/home/git.nix
    ../modules/home/neovim.nix
    ../modules/home/starship.nix
    ../modules/home/tmux.nix
    ../modules/home/wezterm.nix
    ../modules/home/codex.nix
    ../modules/home/niri.nix
    ../modules/home/fcitx5.nix
    ../modules/home/toshy.nix
    ../modules/home/dms.nix
    ../modules/home/mihomo.nix
  ];

  programs.home-manager.enable = true;
}
