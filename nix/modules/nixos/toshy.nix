{
  hardware.uinput.enable = true;

  services.toshy = {
    enable = true;
    users = [ "kyss" ];
  };
}
