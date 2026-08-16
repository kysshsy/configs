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
      mkNixos = hardwareModule: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
        dev-bare-metal = mkNixos ./nix/hardware/dev-bare-metal.nix;
        pve-niri-vm = mkNixos ./nix/hardware/pve-niri-vm.nix;
      };
    };
}
