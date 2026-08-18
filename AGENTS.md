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
  track it in the current Git worktree. Use an out-of-store symlink for mutable
  runtime configuration only when application-written changes are intentionally
  version-controlled; otherwise keep the application's runtime file writable
  and avoid overlapping ownership with Home Manager.

## Configuration Ownership Policy

- Reusable user-level software configuration, such as Codex, shell, editor, and
  terminal configuration, should live in the portable repository groups and be
  installed through symlinks or GNU Stow. On NixOS, Home Manager may reference
  those same repository files rather than duplicating them under `nix/`.
- System-integrated desktop software, such as DankMaterialShell (DMS) and Niri,
  must be configured declaratively with NixOS, Home Manager, or native Nix
  options. Do not manage their entire configuration directories with
  out-of-store symlinks merely for convenience.
- For DMS, Niri, and similar Nix-managed components, keep static configuration
  under the appropriate `nix/` modules or data files and leave application
  settings, history, caches, and other mutable runtime state in their normal
  writable XDG directories. Manage individual third-party plugins with Nix or
  the application's plugin manager instead of implicitly versioning a whole
  runtime directory.

## Application-Writable Configuration

- Treat files linked from `/nix/store` as immutable. Static configuration that
  an application only reads may be managed directly by Nix or Home Manager.
- If an application saves settings, rewrites its configuration, or exposes a
  settings UI that persists changes, do not manage that exact runtime path as
  a Home Manager store link. Let the application own a real writable file in
  its XDG configuration directory or application data directory.
- Prefer an application-supported include or writable override. Otherwise,
  seed a writable file only when it does not exist and leave subsequent edits
  to the application. Use an out-of-store symlink only when writing back to the
  repository is an intentional choice.
- Keep application history, databases, state, and caches in writable user
  directories such as `~/.local/state`, `~/.local/share`, and `~/.cache`; do
  not version-control them unless there is a specific reason.
- Identify applications needing this treatment before deployment when
  possible: check their documentation, inspect `readlink -f` for managed
  runtime files, and use file-access tracing when behavior is unclear. Do not
  wait for a write failure if the application is known to self-modify its
  configuration.

## Nix Structure and Ownership

- `flake.nix` is the public entry point. It defines external inputs and
  exposes machine targets; it should not be the main place where a machine's
  feature selection is listed.
- `nix/hosts/<machine>/default.nix` is the final composition for one machine.
  It selects that machine's hardware profile, NixOS modules, and the Home
  Manager modules used by its users.
- A host directory represents a final deployable target exposed by the Flake.
  Keep its name short and oriented toward the machine's role or user-facing
  function, such as `workstation` or `niri-desktop`; it does not need to match
  the hardware profile name. Hardware profiles may use more descriptive names
  that include architecture, platform, virtualization, or storage details.
- `nix/hardware/` contains machine facts such as generated filesystem,
  bootloader, kernel-module, and virtualization settings. Do not put desktop,
  application, or user policy in hardware profiles.
- System modules belong under `nix/modules/nixos/` and must use native NixOS
  options where those options exist. Keep system services, hardware access,
  users, networking, and boot configuration at this level.
- User modules belong under `nix/modules/home/` and must be loaded through
  Home Manager. Organize them by application or independent function, such as
  `neovim.nix`, `wezterm.nix`, or `git.nix`; do not create broad `editor` or
  `terminal` buckets merely for categorization. If an application's module is
  complex, use `nix/modules/home/<app>/default.nix` and keep its related files
  in that directory.
- An application does not need a module just because it is installed. Keep
  packages with no configuration in the relevant host or user package list.
  Create an application module when it has declarative options, service
  configuration, environment setup, or repository configuration to link.
- `modules` should usually contain one application or one independent feature
  per file. Small tools that only need to be installed and have no meaningful
  configuration may be grouped in a clearly named category module, such as
  `cli-tools.nix`; do not create one module per trivial command.
- Portable application configuration remains in the top-level Stow groups
  (`shell/`, `editor/`, `terminal/`, and similar). A Home Manager module may
  reference those repository files with relative paths; do not duplicate the
  same dotfile under `nix/` solely for NixOS.
- Keep operating-system-specific modules separate. NixOS modules belong under
  `nix/modules/nixos/`; future nix-darwin modules belong under
  `nix/modules/darwin/`. Shared user-level configuration can live under
  `nix/modules/home/`, but it must not assume NixOS-only options.
- Software installation is host-specific. A Linux host may install an
  application with Nix, while a Darwin host may install it with Homebrew;
  both hosts can still load the same Home Manager application configuration.
- Keep one repository-level `flake.lock` for compatible targets. Hardware and
  host selection belong in the target configuration, not in separate lock
  files, unless a platform genuinely requires an independent dependency set.
