{ pkgs, ... }:

{
  # GNOME Desktop
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.gnome3.gnome-keyring.enable = true;

  # ...Remove GNOME packages I don't want
  environment.gnome3.excludePackages = with pkgs.gnome3; [
    epiphany
    geary
    gnome-logs
    gnome-maps
    gnome-music
    gnome-photos
    vino
  ];

  # ...Add GNOME packages I do want
  environment.systemPackages = with pkgs.gnome3; [
    dconf-editor
    gnome-tweaks
  ];
}
