{ lib, pkgs, ... }:

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
    pass
    python3
    uv
    vtsls
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    hwinfo
  ] ++ [ proximity-sort ];
}
