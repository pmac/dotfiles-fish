{ pkgs, config, ... }:

{
  # Overrides
  nixpkgs.config.packageOverrides = pkgs: {
    neovim = pkgs.neovim.override {
      vimAlias = true;
      viAlias = true;
    };
  };

  environment.variables = {
    EDITOR = pkgs.lib.mkForce "nvim";

    # Trick firefox so it doesn't create new profiles
    # https://github.com/mozilla/nixpkgs-mozilla/issues/163
    SNAP_NAME = "firefox";

    # Make Firefox scroll better in Xorg
    MOZ_USE_XINPUT2="1";
  };

  # Nuke the default shell aliases.
  # They take precedence over user-defined functions in Fish.
  environment.shellAliases = pkgs.lib.mkForce { };

  # Packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Basic Console Utilities
    bc
    bind.dnsutils # dig, nslookup, ...
    bind.host
    curl
    file
    git
    gnupg
    lesspipe
    lsof
    psmisc # pstree, killall, ...
    rsync
    tree
    wget
    which
    whois

    # Linux-Specific Utilities
    efibootmgr
    exfat
    lshw
    pciutils
    powertop
    thunderbolt
    usbutils # lsusb

    # Enhanced Console Utilities
    bat
    exa
    fd
    fish
    htop
    neovim
    ripgrep

    # Archives
    atool
    p7zip
    unrar
    unzip
    zip

    # Backup
    restic
  ];

  # Fonts
  fonts.enableDefaultFonts = false;
  #     Default fonts we skip:
  #     gyre-fonts, misc xorg fonts, lucida typewriter, unifont 
  fonts.enableFontDir = true;
  fonts.fontconfig.allowBitmaps = false;
  fonts.fonts = with pkgs; [
      cantarell_fonts
      # corefonts
      dejavu_fonts
      fira-code
      fira-code-symbols
      freefont_ttf
      ibm-plex
      iosevka-bin
      inconsolata-lgc
      input-fonts
      liberation_ttf
      monoid
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-code-pro
  ];

  # Services
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brgenml1cupswrapper ];
  services.flatpak.enable = true;
  services.pcscd.enable = true;
  sound.enable = true;
  virtualisation.docker.enable = true;
  hardware.u2f.enable = true;

  hardware.sane.enable = true;
  hardware.sane.dsseries.enable = true;

  # Sway Window Manager
  #programs.sway = {
  #  enable = true;
  #  extraSessionCommands = ''
  #    export SDL_VIDEODRIVER=wayland
  #    export QT_QPA_PLATFORM=wayland
  #    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
  #    export _JAVA_AWT_WM_NONREPARENTING=1
  #    export XDG_SESSION_TYPE=wayland
  #    export KITTY_ENABLE_WAYLAND=1
  #    export GDK_BACKEND=wayland
  #    export MOZ_ENABLE_WAYLAND=1
  #    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$EGL_LD_PATH"
  #  '';
  #};

  # GNOME Desktop
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.gnome3.gnome-keyring.enable = true;
  services.xserver.desktopManager.xterm.enable = false;

  # Caps Lock is Control. Always.
  i18n.consoleUseXkbConfig = true;
  services.xserver.xkbOptions = "ctrl:nocaps";

  environment.gnome3.excludePackages = with pkgs.gnome3; [
    accerciser
    epiphany
    evolution
    gnome-documents
    gnome-logs
    gnome-maps
    gnome-music
    gnome-photos
    gnome-software # works very poorly on NixOS
    gnome-todo
    gnome-usage # not yet as good as gnome-system-monitor
    gucharmap
    vinagre # VNC client
    vino # Integrated VNC server
  ];

  # Sonos?
  # See: https://github.com/janbar/noson-app/issues/9
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 1400 1401 1402 1403 1404 1405 1406 1407 1408 1409 3400 3401 3500 ];
  networking.firewall.allowedUDPPorts = [ 1900 1901 ];

  # Users
  programs.fish.enable = true;

  users.users.dan = {
    isNormalUser = true;
    description = "Dan Callahan";
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [
      "wheel" "audio" "video" "scanner"
      "networkmanager" "systemd-journal"
      "docker" "sway"
    ];
  };

}
