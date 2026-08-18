{ dms, toshy, ... }:

{
  imports = [
    ../../hardware/x86_64-linux-intel-bare-metal.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/user-kyss.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/fcitx5.nix
    ../../modules/nixos/toshy.nix
    ../../modules/nixos/ssh.nix
  ];

  home-manager.users.kyss = {
    imports = [
      dms.homeModules.dank-material-shell
      toshy.homeManagerModules.toshy
      ../../home/kyss.nix
    ];
  };
}
