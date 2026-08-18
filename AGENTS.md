# Repository Maintenance Rules

This repository supports more than NixOS.

- `shell/`, `editor/`, `terminal/`, and similar top-level groups are portable
  dotfiles. On non-Nix hosts, install the required groups with GNU Stow.
- `nix/` contains NixOS and Home Manager integration. It may reference a
  subset of the portable dotfiles and may add Nix-specific configuration.
- A file that is not imported by Nix is not obsolete. It can still be needed
  by Stow users, another operating system, or a machine-specific workflow.
- Do not delete portable dotfiles merely because they contain settings that
  NixOS does not use, such as Arch package helpers, local toolchains, proxies,
  or host-specific paths. Keep them unless they are confirmed unused across
  the supported workflows.
- Before deleting a configuration file, check its Stow group, repository
  references, documentation, and intended non-Nix use. Prefer isolating or
  conditionally loading host-specific settings when that improves portability.
- Do not use Stow on NixOS for paths owned by Home Manager. Avoid overlapping
  ownership; Nix should reference the repository source directly instead.
- When adding or changing software configuration, decide whether it should be
  version-controlled. If it should, add the source to this repository and
  track it in the current Git worktree; prefer an out-of-store symlink to that
  source for mutable runtime configuration, while avoiding ownership conflicts
  with Home Manager.
