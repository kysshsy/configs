{ config, pkgs, lib, ... }:

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
  # Seed a writable local config once; later activation never replaces it.
  home.activation.initializeMihomoConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mihomo_dir="$HOME/.config/mihomo"
    mihomo_config="$mihomo_dir/config.yaml"
    if [ ! -e "$mihomo_config" ]; then
      install -d -m 700 "$mihomo_dir"
      cat > "$mihomo_config" <<'EOF'
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info
external-controller: 127.0.0.1:9097
proxies: []
proxy-groups:
  - name: GLOBAL
    type: select
    proxies:
      - DIRECT
rules:
  - MATCH,GLOBAL
EOF
      chmod 600 "$mihomo_config"
    fi
  '';

  systemd.user.services.mihomo = {
    Unit = {
      Description = "Mihomo proxy core";
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
    "niri/config.kdl".source = ./niri.kdl;
    "wezterm/wezterm.lua".source = ../../terminal/.config/wezterm/wezterm.lua;
  };

  home.file.".tmux.conf".source = ../../shell/.tmux.conf;
  home.file.".codex/config.toml".source = ../../agentic/.codex/config.toml;
  programs.home-manager.enable = true;
}
