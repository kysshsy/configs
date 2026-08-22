# Repository Rules

## Configuration Ownership

1. Keep portable, user-editable dotfiles in top-level Stow groups such as
   `shell/`, `editor/`, and `terminal/`. Non-Nix machines install those groups
   with GNU Stow.
2. Use Nix for package installation, system configuration, and most software
   configuration. When a portable configuration is substantial or benefits
   from reuse outside Nix, keep it in a top-level Stow group and let the
   relevant Nix module reference it.
3. A module under `nix/modules/` configures one application or cohesive
   capability. Application configuration modules do not install packages.
   Shared package groups, such as `cli-tools.nix`, are the exception: they
   declare a portable user-facing package set for every applicable platform.

## Reproducibility And Safety

4. Keep configurations reproducible. Declare required packages, inputs, and
   settings in this repository, then verify every affected target after a
   change.
5. Do not introduce unnecessary absolute paths, machine-specific values, or
   hard-coded assumptions. Keep unavoidable host-specific values in the
   relevant host configuration and explain why they are needed.
6. Never commit secrets, tokens, passwords, private keys, or credentials.
   Reference externally managed secret material instead.

## Documentation

Keep `README.md` limited to the repository overview, supported targets, and
commands needed to install, deploy, or check a configuration. Keep maintenance
and contributor rules in this file.
