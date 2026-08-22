{ config, ... }:

{
  # Codex can update its own configuration, so keep these files as writable
  # links into the checkout instead of immutable Home Manager store links.
  # The repository is expected at ~/configs on supported machines.
  home.file.".codex/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/agentic/.codex/config.toml";
  };

  home.file.".codex/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/agentic/.codex/AGENTS.md";
  };
}
