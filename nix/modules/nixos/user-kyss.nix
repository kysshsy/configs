{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.kyss = {
    isNormalUser = true;
    description = "kyss";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
  };
}
