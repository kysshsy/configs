{ pkgs, userName, ... }:

{
  programs.fish.enable = true;

  users.users.${userName} = {
    isNormalUser = true;
    description = userName;
    shell = pkgs.fish;
    linger = true;
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
  };
}
