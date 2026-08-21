{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.kyss = {
    isNormalUser = true;
    description = "kyss";
    shell = pkgs.fish;
    linger = true;
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
  };
}
