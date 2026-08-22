{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    gh
    bat
    # `rustup` supplies the `cargo` and `rustc` command proxies, then manages
    # the selected Rust toolchain consistently on macOS and Linux.
    rustup
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
