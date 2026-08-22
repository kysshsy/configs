{ lib, pkgs, ... }:

{
  # Change this if this configuration is deployed to a differently named Mac.
  networking.hostName = "macos";
  networking.computerName = "macos";

  # Required by nix-darwin's activation scripts when they run through sudo.
  system.primaryUser = "kyss";
  system.stateVersion = 6;

  # Make the shared WezTerm font available to native macOS applications.
  fonts.packages = [ pkgs.dejavu_fonts ];

  # Make the migrated Fish environment the default login shell for the user.
  programs.fish.enable = true;
  programs.fish.package = pkgs.fish;
  environment.shells = [ pkgs.fish ];
  users.users.kyss.shell = pkgs.fish;
  # The account predates nix-darwin, so update its Directory Services record
  # explicitly instead of relying on user creation to apply the shell setting.
  system.activationScripts.postActivation.text = ''
    dscl . -create /Users/kyss UserShell /run/current-system/sw/bin/fish
  '';

  # Determinate Nix owns the Nix daemon and installation on this machine.
  nix.enable = false;

  nix-homebrew = {
    enable = true;
    user = "kyss";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # Native macOS GUI applications belong to Homebrew casks; keep Nix focused
    # on reproducible command-line and developer tooling.
    brews = [ "mas" ];
    casks = [
      "codex"
      "visual-studio-code"
      "google-chrome"
      "mos"
    ];
    # Temporarily disabled: `mas` 7 requires root privileges for installation,
    # while nix-darwin runs Homebrew Bundle as the primary user.
    # masApps = {
    #   "PasteNow - 剪贴板工具" = 1552536109;
    #   "Longshot - 截图 & OCR文字识别" = 6450262949;
    #   "自动切换输入法Lite" = 1552555103;
    #   "Hidden Bar" = 1452453066;
    # };
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Keep Homebrew software that is managed outside this configuration.
      cleanup = "none";
    };
  };

  # Disable the global Cmd+Space Spotlight shortcut while leaving Spotlight
  # indexing and manual searches available.
  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
    AppleSymbolicHotKeys."64" = {
      enabled = false;
      value = {
        parameters = [ 65535 32 1048576 ];
        type = "standard";
      };
    };
  };

  # Keep Dock services available while removing the persistent Dock bar.
  system.defaults.dock = {
    autohide = true;
    show-recents = false;
  };

  # Keep Codex user configuration shared with the NixOS Home Manager setup,
  # without importing Linux-only desktop modules on macOS.
  home-manager.users.kyss = {
    home.username = "kyss";
    # nix-darwin contributes a null default for this option; force the actual
    # Darwin home directory so Home Manager can evaluate the user profile.
    home.homeDirectory = lib.mkForce "/Users/kyss";
    home.stateVersion = "26.05";

    imports = [
      ../../modules/home/cli-tools.nix
      ../../modules/home/nodejs.nix
      ../../modules/home/fish.nix
      ../../modules/home/git.nix
      ../../modules/home/neovim.nix
      ../../modules/home/starship.nix
      ../../modules/home/tmux.nix
      ../../modules/home/wezterm.nix
      ../../modules/home/codex.nix
    ];

    programs.home-manager.enable = true;
  };

  # Preserve any pre-existing Codex files during the first activation.
  home-manager.backupFileExtension = "codex-backup";
}
