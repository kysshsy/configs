{ lib, pkgs, userName, ... }:

let
  homeDirectory = "/Users/${userName}";
  configurationDirectory = "${homeDirectory}/configs";
  localProxyUrl = "http://127.0.0.1:7890";
  masAppIds = [
    "1552536109" # PasteNow
    "6450262949" # Longshot
    "1552555103" # 自动切换输入法Lite
    "1452453066" # Hidden Bar
  ];
in
{
  # Change this if this configuration is deployed to a differently named Mac.
  networking.hostName = "macos";
  networking.computerName = "macos";

  # Required by nix-darwin's activation scripts when they run through sudo.
  system.primaryUser = userName;
  system.stateVersion = 6;

  # Make the shared WezTerm font available to native macOS applications.
  fonts.packages = [ pkgs.dejavu_fonts ];

  # `sudo` removes terminal proxy variables. Probe the local VPN proxy for
  # each command and pass it through so nix-darwin's Brew Bundle activation
  # can use it without leaving a stale proxy when the VPN client is stopped.
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "nix-rebuild";
      text = ''
        if curl --silent --output /dev/null --connect-timeout 1 --max-time 1 ${localProxyUrl}; then
          exec sudo env \
            http_proxy=${localProxyUrl} https_proxy=${localProxyUrl} \
            HTTP_PROXY=${localProxyUrl} HTTPS_PROXY=${localProxyUrl} \
            nix run nix-darwin -- switch --flake ${configurationDirectory}#macos "$@"
        fi

        exec sudo nix run nix-darwin -- switch --flake ${configurationDirectory}#macos "$@"
      '';
    })
    (pkgs.writeShellApplication {
      name = "nix-build";
      text = ''
        if curl --silent --output /dev/null --connect-timeout 1 --max-time 1 ${localProxyUrl}; then
          exec env \
            http_proxy=${localProxyUrl} https_proxy=${localProxyUrl} \
            HTTP_PROXY=${localProxyUrl} HTTPS_PROXY=${localProxyUrl} \
            nix build --no-write-lock-file ${configurationDirectory}#darwinConfigurations.macos.system "$@"
        fi

        exec nix build --no-write-lock-file ${configurationDirectory}#darwinConfigurations.macos.system "$@"
      '';
    })
    (pkgs.writeShellApplication {
      name = "mas-install-apps";
      text = ''
        if ! command -v brew >/dev/null; then
          echo "mas-install-apps: Homebrew is not available" >&2
          exit 1
        fi

        mas_bin="$(brew --prefix mas)/bin/mas"
        if [ ! -x "$mas_bin" ]; then
          echo "mas-install-apps: install the mas Homebrew formula first" >&2
          exit 1
        fi

        exec sudo "$mas_bin" get ${lib.escapeShellArgs masAppIds}
      '';
    })
  ];

  # Make the migrated Fish environment the default login shell for the user.
  programs.fish.enable = true;
  programs.fish.package = pkgs.fish;
  environment.shells = [ pkgs.fish ];
  users.users.${userName}.shell = pkgs.fish;
  # The account predates nix-darwin, so update its Directory Services record
  # explicitly instead of relying on user creation to apply the shell setting.
  system.activationScripts.postActivation.text = ''
    dscl . -create ${homeDirectory} UserShell /run/current-system/sw/bin/fish
  '';

  # Determinate Nix owns the Nix daemon and installation on this machine.
  nix.enable = false;

  nix-homebrew = {
    enable = true;
    user = userName;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # Native macOS GUI applications belong to Homebrew casks; keep Nix focused
    # on reproducible command-line and developer tooling.
    taps = [ "nikitabobko/tap" ];
    brews = [ "mas" ];
    casks = [
      "nikitabobko/tap/aerospace"
      "codex"
      "visual-studio-code"
      "google-chrome"
      "mos"
      "betterdisplay"
    ];
    # `mas` 7 needs root for App Store installs, while nix-darwin runs Brew
    # Bundle as the primary user. Use `mas-install-apps` after deployment.
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # Keep Homebrew software that is managed outside this configuration.
      cleanup = "none";
    };
  };

  # Disable the global Cmd+Space Spotlight shortcut while leaving Spotlight
  # indexing and manual searches available. Keep both search assistants out of
  # the menu bar as well.
  system.defaults.CustomUserPreferences."com.apple.Siri".StatusMenuVisible = false;
  system.defaults.CustomUserPreferences."com.apple.Spotlight".MenuItemHidden = true;
  # Do not reveal the desktop and move application windows aside when the
  # wallpaper is clicked.
  system.defaults.CustomUserPreferences."com.apple.WindowManager".EnableStandardClickToShowDesktop = false;
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
  home-manager.users.${userName} = {
    home.username = userName;
    # nix-darwin contributes a null default for this option; force the actual
    # Darwin home directory so Home Manager can evaluate the user profile.
    home.homeDirectory = lib.mkForce homeDirectory;
    home.stateVersion = "26.05";

    imports = [
      ../../modules/home/cli-tools.nix
      ../../modules/home/nodejs.nix
      ../../modules/home/fish.nix
      ../../modules/home/proxy.nix
      ../../modules/home/aerospace.nix
      ../../modules/home/git.nix
      ../../modules/home/neovim.nix
      ../../modules/home/starship.nix
      ../../modules/home/tmux.nix
      ../../modules/home/wezterm.nix
      ../../modules/home/codex.nix
    ];

    localProxy = {
      enable = true;
      url = localProxyUrl;
    };

    programs.home-manager.enable = true;
  };

  # Preserve existing user-managed files before Home Manager replaces them.
  home-manager.backupFileExtension = "home-manager-backup";
}
