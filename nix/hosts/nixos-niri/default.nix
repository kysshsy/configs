{ configurationName, pkgs, ... }:

{
  imports = [
    ../../modules/niri.nix
    ../../modules/ssh.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  # Toshy emits remapped keystrokes through /dev/uinput.  The NixOS module
  # owns the device rule and grants access to members of the uinput group.
  hardware.uinput.enable = true;

  services.toshy = {
    enable = true;
    users = [ "kyss" ];
  };

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
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [
      (pkgs.fcitx5-rime.override {
        rimeDataPkgs = [ pkgs.rime-ice ];
      })
    ];
  };
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

  programs.fish.enable = true;

  users.users.kyss = {
    isNormalUser = true;
    description = "kyss";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
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

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    google-chrome
    nano
    nodejs_22
    vscode
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
        exec sudo nixos-rebuild switch --flake /home/kyss/configs#${configurationName} "$@"
      '';
    })
  ];

  system.stateVersion = "26.05";
}
