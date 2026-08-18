{
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # This dedicated workstation key grants Mac-to-NixOS access. GitHub deploy
  # keys remain separate and are added only when a private repository needs it.
  users.users.kyss.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDPYwCQYTUBqBz7ai0SwH+Uq3tXeEsetGhzqov+fpta kyss@nixos"
  ];
}
