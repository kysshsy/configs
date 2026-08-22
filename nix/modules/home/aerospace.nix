{ config, ... }:

{
  # AeroSpace reloads this file after it is saved, so use a writable link into
  # the repository instead of a read-only link into the Nix store.
  home.file.".aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/configs/aerospace/.aerospace.toml";
}
