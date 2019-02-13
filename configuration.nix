# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # === Extra hardware support === {{{
  # See: https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix 
  boot.initrd.kernelModules = [ "i915" "thunderbolt" ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
  # }}}

  # === Boot Configuration ===
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ {
    name = "opal-config";
    patch = null;
    extraConfig = ''
      BLK_SED_OPAL y
    '';
  } ];

  nixpkgs.config.packageOverrides = pkgs: {
    sedutil = (pkgs.sedutil.overrideAttrs (oldAttrs: rec {
      name = "sedutil-${version}-s3patched";
      version = "1.15.1";

      src = pkgs.fetchFromGitHub {
        owner  = "badicsalex";
        repo   = "sedutil";
        rev    = "ecfd482016d41d035d9f128e91a51f107230a735"; # tip of branch s3-sleep-support
        sha256 = "1z2zmvah0n05f6sq83fw8c0lzlvqk1nvh3604j90h38mrhhjgvs2";
      };
    }));
  };

  # === System Configuration ===
  networking.hostName = "meta"; # Define your hostname.
  time.timeZone = "Europe/Belfast";

  # === Packages ===
  # Allow unfree packages (like Firefox?!)
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    cmus
    docker_compose
    exa
    atool
    fd
    firefox
    vlc
    fish
    git
    gitAndTools.hub
    gitg
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    htop
    libreoffice
    file
    lsof
    neovim
    pciutils
    ripgrep
    thunderbolt
    powertop
    tig
    tree
    vim
    wget
    sxiv
    ranger
    sedutil
    digikam
    restic
    kitty
    calibre
  ];

  programs.fish.enable = true;

  systemd.services.sedutil-s3sleep = {
    description = "Enable S3 sleep on OPAL self-encrypting drives";
    documentation = [ "https://github.com/Drive-Trust-Alliance/sedutil/pull/190" ];
    path = [ pkgs.sedutil ];
    script = "sedutil-cli -n -x --prepareForS3Sleep 0 ***REMOVED*** /dev/nvme0n1";
    wantedBy = [ "multi-user.target" ];
  };

  # See https://www.kernel.org/doc/html/latest/admin-guide/pm/sleep-states.html#basic-sysfs-interfaces-for-system-suspend-and-hibernation
  # Force hybrid-sleep on suspend:
  #   - When suspending, write RAM to disk (hibernate)
  #   - When done writing hibernation image, suspend.
  environment.etc."systemd/sleep.conf".text = pkgs.lib.mkForce ''
    [Sleep]
    SuspendState=disk
    SuspendMode=suspend
  '';

  services.tlp.enable = true;
  services.printing.enable = true;

  sound.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  environment.gnome3.excludePackages = with pkgs.gnome3; [
    # epiphany # GNOME Web
    # gnome-software
    accerciser
    evolution
    gnome-documents
    gnome-maps
    gnome-music
    gnome-photos
    gnome-todo
    gnome-usage # not yet as good as gnome-system-monitor
    gucharmap
    vinagre # VNC client
    vino # Integrated VNC server
  ];

  services.flatpak.enable = true;
  virtualisation.docker.enable = true;

  users.users.dan = {
    isNormalUser = true;
    description = "Dan Callahan";
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [
      "wheel" "disk" "audio" "video"
      "docker" "networkmanager" "scanner" "systemd-journal"
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
