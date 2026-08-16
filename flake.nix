{
  description = "kyss's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # GitHub archive downloads are unreliable on this network. The lock file
    # pins the unpacked source hash, so this transport mirror cannot alter it.
    dms.url = "tarball+https://ghfast.top/https://github.com/AvengeMedia/DankMaterialShell/archive/069ddab041c738236a8910e4c39b65d9628d3018.tar.gz";
  };

  outputs = { nixpkgs, home-manager, dms, ... }:
    let
      mkNixos = { hardwareModule, configurationName }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.configurationName = configurationName;
        modules = [
          hardwareModule
          ./nix/hosts/nixos-niri
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kyss = {
              imports = [
                dms.homeModules.dank-material-shell
                ./nix/home/kyss.nix
              ];
            };
          }
        ];
      };
    in {
      nixosConfigurations = {
        dev-bare-metal = mkNixos {
          hardwareModule = ./nix/hardware/dev-bare-metal.nix;
          configurationName = "dev-bare-metal";
        };
        pve-niri-vm = mkNixos {
          hardwareModule = ./nix/hardware/pve-niri-vm.nix;
          configurationName = "pve-niri-vm";
        };
      };
    };
}
