{ config, ... }:

{
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/agentic/.codex/config.toml";
}
