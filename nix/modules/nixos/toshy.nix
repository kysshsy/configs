{ userName, ... }:
{
  hardware.uinput.enable = true;

  services.toshy = {
    enable = true;
    users = [ userName ];
  };
}
