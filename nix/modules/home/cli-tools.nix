{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    gh
    bat
    eza
    fastfetch
    fd
    tree
    zoxide
    fzf
    jq
    ripgrep
    tldr
    ugrep
    hwinfo
    pass
  ];
}
