{ pkgs, ... }:

{
  programs.niri.enable = true;
  security.polkit.enable = true;

  # Greetd keeps the desktop lightweight while providing a local graphical
  # login on either a physical display or a virtual console.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
      user = "greeter";
    };
  };

  # Portals provide file pickers, screen sharing, and other desktop IPC.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
