# Hardware Profiles

Each file in this directory describes hardware that cannot be safely shared
between machines, such as filesystem UUIDs, boot partitions, and platform
drivers. Select a profile through a named Flake output rather than importing a
hardware file from shared modules.

To add a machine, generate its file after installation:

```bash
sudo nixos-generate-config
```

Copy `/etc/nixos/hardware-configuration.nix` here under a new descriptive
name, add a matching `nixosConfigurations` entry in the root `flake.nix`, and
rebuild with that output name.
