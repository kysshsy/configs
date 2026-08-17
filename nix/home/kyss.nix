{ config, pkgs, ... }:

{
  home.username = "kyss";
  home.homeDirectory = "/home/kyss";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Cloud and developer service clients.
    awscli2
    gh

    # Network and proxy client.
    clash-verge-rev
    mihomo

    # File viewing and directory navigation.
    bat
    eza
    fastfetch
    fd
    tree
    zoxide

    # Interactive search, command help, and structured/text data queries.
    fzf
    jq
    ripgrep
    tldr
    ugrep

    # Security and local system inspection.
    hwinfo
    pass

    # Terminal applications.
    neovim
    starship
    tmux
    wezterm
    (writeShellApplication {
      name = "focus-or-spawn";
      runtimeInputs = [ jq niri ];
      text = ''
        app_id="$1"
        shift

        # Prefer an existing matching window that is not currently focused.
        window_id="$(niri msg --json windows | jq -r --arg app_id "$app_id" '
          [.[] | select(.app_id == $app_id) | { id, is_focused }]
          | sort_by(.is_focused)
          | .[0].id // empty
        ')"

        if [ -n "$window_id" ]; then
          exec niri msg action focus-window --id "$window_id"
        fi

        exec "$@"
      '';
    })
    (writeShellApplication {
      name = "mac-app-key";
      runtimeInputs = [ jq niri wtype ];
      text = ''
        key="$1"
        app_id="$(niri msg --json focused-window | jq -r '.app_id // empty')"

        case "$app_id" in
          google-chrome)
            # Chromium only recognizes Ctrl+2's NUL character when the
            # synthetic key occupies the standard Digit2 keycode.
            if [ "$key" = "2" ]; then
              exec wtype -k F13 -k F14 -M ctrl "$key"
            fi
            exec wtype -M ctrl "$key"
            ;;
          org.wezfurlong.wezterm)
            exec wtype -M ctrl "$key"
            ;;
          *)
            if [ "$key" = "w" ]; then
              exec niri msg action close-window
            fi
            ;;
        esac
      '';
    })
  ];

  # The DMS package/version comes from the flake input. Its mutable settings
  # live in this checkout through out-of-store directory symlinks, so changes
  # made in the DMS UI are visible to Git immediately.
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableAudioWavelength = false;
    enableCalendarEvents = false;
    enableDynamicTheming = false;
  };

  xdg.configFile."DankMaterialShell" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/nix/dms/config";
    force = true;
  };

  home.file.".local/state/DankMaterialShell" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/configs/nix/dms/state";
    force = true;
  };

  # Mihomo runs independently from the optional Clash Verge graphical client.
  # The private configuration must contain a real subscription before startup.
  systemd.user.services.mihomo = {
    Unit = {
      Description = "Mihomo proxy core";
      ConditionPathExists = "%h/.config/mihomo/config.yaml";
    };
    Service = {
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d %h/.config/mihomo";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Node.js itself is immutable in the Nix store. npm therefore installs Codex
  # under the user's home directory instead of attempting to mutate Nix files.
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-packages";
  home.sessionPath = [ "${config.home.homeDirectory}/.npm-packages/bin" ];
  home.file.".npmrc".text = "prefix=${config.home.homeDirectory}/.npm-packages\n";
  programs.bash = {
    enable = true;
    # Interactive SSH shells read .bashrc, not necessarily .profile.
    bashrcExtra = ''
      export PATH="$HOME/.npm-packages/bin:$PATH"
    '';
  };

  # Nix consumes only a portable subset of the shared Stow dotfiles. Fish is
  # linked item by item so its fish_variables state remains writable.
  xdg.configFile = {
    "fish/config.fish".source = ../../shell/.config/fish/config.fish;
    "fish/completions".source = ../../shell/.config/fish/completions;
    "fish/conf.d".source = ../../shell/.config/fish/conf.d;
    "fish/functions".source = ../../shell/.config/fish/functions;
    "fish/manual".source = ../../shell/.config/fish/manual;
    "git/config".source = ../../shell/.config/git/config;
    "nvim".source = ../../editor/.config/nvim;
    "starship.toml".source = ../../shell/.config/starship.toml;
    "fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=rime

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=rime
      Layout=

      [GroupOrder]
      0=Default
    '';
    "fcitx5/conf/global.conf".text = ''
      [Behavior]
      ShareInputState=No
      ResetStateWhenFocusIn=No
    '';
    "niri/config.kdl".source = ./niri.kdl;
    "niri/niri-shortcuts.kdl".source = ./niri-shortcuts.kdl;
    "wezterm/wezterm.lua".source = ../../terminal/.config/wezterm/wezterm.lua;
  };

  # Rime reads user schemas from XDG data. Xiaohe double pinyin emits
  # simplified Chinese by default.
  xdg.dataFile = {
    "icons/hicolor/scalable/apps/fcitx-rime.svg".source =
      "${pkgs.fcitx5-rime}/share/icons/hicolor/scalable/apps/org.fcitx.Fcitx5.fcitx-rime.svg";
    "fcitx5/rime/default.custom.yaml".text = ''
      patch:
        __include: rime_ice_suggestion:/
        schema_list:
          - schema: double_pinyin_flypy
    '';
    "fcitx5/rime/double_pinyin_flypy.custom.yaml".text = ''
      patch:
        "switches/@2/reset": 0
    '';
  };

  home.file.".tmux.conf".source = ../../shell/.tmux.conf;
  home.file.".codex/config.toml".source = ../../agentic/.codex/config.toml;
  programs.home-manager.enable = true;
}
