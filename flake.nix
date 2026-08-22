{
  description = "kyss's NixOS and macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # GitHub archive downloads are unreliable on this network. The lock file
    # pins the unpacked source hash, so this transport mirror cannot alter it.
    dms.url = "tarball+https://ghfast.top/https://github.com/AvengeMedia/DankMaterialShell/archive/069ddab041c738236a8910e4c39b65d9628d3018.tar.gz";
    toshy = {
      url = "git+https://github.com/RedBearAK/toshy.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, nix-homebrew, dms, toshy, ... }:
    let
      userName = "kyss";
      mkNixos = { targetName, hostModule }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit targetName userName dms toshy; };
        modules = [
          toshy.nixosModules.toshy
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit userName dms toshy; };
          }
          hostModule
        ];
      };
      mkDarwin = { hostModule }: nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit userName; };
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit userName; };
          }
          hostModule
        ];
      };
    in {
      nixosConfigurations = {
        workstation = mkNixos {
          targetName = "workstation";
          hostModule = ./nix/hosts/workstation;
        };
        pve-guest = mkNixos {
          targetName = "pve-guest";
          hostModule = ./nix/hosts/pve-guest;
        };
      };
      darwinConfigurations.macos = mkDarwin {
        hostModule = ./nix/hosts/macos;
      };
    };
}
