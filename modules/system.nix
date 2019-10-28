{ pkgs, ... }:

{
  # General Services
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.flatpak.enable = true;
  services.fwupd.enable = true;
  services.pcscd.enable = true;
  sound.enable = true;
  hardware.u2f.enable = true;

  # Printing / Scanning
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brgenml1cupswrapper ];
  hardware.sane.enable = true;
  hardware.sane.dsseries.enable = true;

  # Keyboard (Caps Lock is Control)
  i18n.consoleUseXkbConfig = true;
  services.xserver.xkbOptions = "ctrl:nocaps";

  # MAC Address Randomization (During Scans)
  #  On by default in upstream NetworkManager 1.2, but disabled in NixOS
  #  See: https://blogs.gnome.org/thaller/2016/08/26/mac-address-spoofing-in-networkmanager-1-4-0/
  networking.networkmanager.wifi.scanRandMacAddress = true;

  # Firewall
  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [
    # Sonos: https://github.com/janbar/noson-app/issues/9
    1400 1401 1402 1403 1404 1405 1406 1407 1408 1409 3400 3401 3500

    # VLC -> Chromecast streaming
    8010
  ];

  networking.firewall.allowedUDPPorts = [ 1900 1901 ];

  # MDN Development
  networking.hosts = {
    "127.0.0.1" = ["mdn.localhost" "beta.mdn.localhost" "wiki.mdn.localhost"];
    "::1" = ["mdn.localhost" "beta.mdn.localhost" "wiki.mdn.localhost"];
  };
}
