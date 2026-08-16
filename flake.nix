{
  description = "kyss's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
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
            home-manager.users.kyss = import ./nix/home/kyss.nix;
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
