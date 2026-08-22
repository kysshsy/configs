{ config, lib, ... }:

let
  cfg = config.localProxy;
in
{
  options.localProxy = {
    enable = lib.mkEnableOption "automatic local HTTP proxy environment";

    url = lib.mkOption {
      type = lib.types.str;
      example = "http://127.0.0.1:7890";
      description = "Local HTTP proxy URL to use while its service is reachable.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Fish probes this endpoint before exporting HTTP(S)_PROXY, so stopping the
    # local VPN client never leaves a stale proxy in the terminal environment.
    home.sessionVariables.LOCAL_HTTP_PROXY_URL = cfg.url;
  };
}
