{ pkgs, ... }:

{
  programs.niri.enable = true;
  security.polkit.enable = true;

  # Greetd keeps the guest lightweight while providing a local graphical login
  # through the PVE console. It is also suitable once the Intel iGPU is passed
  # through for direct HDMI output.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
      user = "greeter";
    };
  };

  # Portals provide file pickers, screen sharing, and other desktop IPC.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
