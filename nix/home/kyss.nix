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
  ];

  # Keep DMS settings mutable during the trial, so its settings UI can adjust
  # panel placement and module order. Once the layout is settled, record it
  # declaratively in this repository.
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableAudioWavelength = false;
    enableCalendarEvents = false;
    enableDynamicTheming = false;
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
    "niri/config.kdl".source = ./niri.kdl;
    "wezterm/wezterm.lua".source = ../../terminal/.config/wezterm/wezterm.lua;
  };

  # Rime reads user schemas from XDG data. Xiaohe double pinyin emits
  # simplified Chinese by default.
  xdg.dataFile = {
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
