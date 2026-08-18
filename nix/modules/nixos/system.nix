{ targetName, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
  };

  # Keep only system maintenance tools here. User applications belong in
  # Home Manager modules.
  environment.systemPackages = with pkgs; [
    curl
    git
    nano
    wget
    (writeShellApplication {
      name = "nix-check";
      text = ''
        exec nix flake check --no-write-lock-file /home/kyss/configs
      '';
    })
    (writeShellApplication {
      name = "nix-rebuild";
      text = ''
        exec sudo nixos-rebuild switch --flake /home/kyss/configs#${targetName} "$@"
      '';
    })
  ];

  system.stateVersion = "26.05";
}
