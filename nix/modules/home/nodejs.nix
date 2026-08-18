{ config, pkgs, ... }:

{
  home.packages = [ pkgs.nodejs_22 ];

  home.sessionVariables.NPM_CONFIG_PREFIX =
    "${config.home.homeDirectory}/.npm-packages";
  home.sessionPath = [ "${config.home.homeDirectory}/.npm-packages/bin" ];
  home.file.".npmrc".text =
    "prefix=${config.home.homeDirectory}/.npm-packages\n";

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export PATH="$HOME/.npm-packages/bin:$PATH"
    '';
  };
}
