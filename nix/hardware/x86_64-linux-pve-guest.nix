# This is copied from the installed PVE guest. Keep the filesystem UUIDs in
# version control so rebuilds always target the existing virtual disk.
{ lib, modulesPath, ... }:

{
  services.qemuGuest.enable = true;

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3302b2a2-a2b9-4ec6-9bbb-6ff7fd6dc8a1";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/82B2-D94D";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
