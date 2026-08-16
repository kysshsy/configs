{ pkgs, ... }:

{
  imports = [
    ../../modules/niri.nix
    ../../modules/ssh.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  services.xserver.xkb.layout = "us";
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  programs.fish.enable = true;

  users.users.kyss = {
    isNormalUser = true;
    description = "kyss";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # USTC is currently faster from this host; keep the official cache as a
    # fallback when a path is not available from the mainland mirror.
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    nano
    nodejs_22
    wget
  ];

  system.stateVersion = "26.05";
}
