{ config, lib, pkgs, ... }:

{
  # Host
  networking.hostName = "meta";
  time.timeZone = "Europe/Belfast";

  # Randomize MAC addresses (stable hashing per connection, resets each boot)
  networking.networkmanager.ethernet.macAddress = "stable";
  networking.networkmanager.wifi.macAddress = "stable";
  networking.networkmanager.extraConfig = ''
    [connection]
    connection.stable-id=''${CONNECTION}/''${BOOT}
  '';


  # Nix Daemon
  nix.maxJobs = lib.mkDefault 4;
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  system.autoUpgrade.enable = true;

  # Power Management
  services.tlp.enable = true;
  services.thermald.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Hardware
  #   https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.s3tcSupport = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver ];
  services.xserver.useGlamor = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "uas" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.tmpOnTmpfs = true;

  # Kernel
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # I need kernel 5.4.2 to get past a regression with i915:
  #   https://bugs.freedesktop.org/show_bug.cgi?id=111805
  # Linux 5.4.2 isn't in Nixpkgs yet:
  #  https://github.com/NixOS/nixpkgs/pull/75144
  # But that's OK, because we can manually define it here
  boot.kernelPackages =
    let
      linux_5_4_pkg = { fetchurl, buildLinux, ... } @ args:
        buildLinux (args // rec {
          version = "5.4.2";
          modDirVersion = version;

          src = fetchurl {
            url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
            sha256 = "0mx50cp61kajya3lfcksw7wksq7ihkqzrzszf4bb19kwhxb85y9j";
          };
          kernelPatches = [];

          extraMeta.branch = "5.4";
        } // (args.argsOverride or {}));
      linux_5_4 = pkgs.callPackage linux_5_4_pkg{};
    in
      pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_5_4);

  boot.kernelParams = [
    "i915.enable_fbc=1" # Save an infinitesimal amount of power by compressing the framebuffer
    "i915.fastboot=1"   # Avoid modesets until we're in a graphical environment
  ];

  # Self-Encrypting Drive (OPAL 2.0 SED)
  nixpkgs.config.packageOverrides = pkgs: {
    sedutil = (pkgs.sedutil.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        # Add support for enabling unlocking when resuming from sleep
        # See: https://github.com/Drive-Trust-Alliance/sedutil/pull/190
        (builtins.fetchurl {
          url = https://patch-diff.githubusercontent.com/raw/Drive-Trust-Alliance/sedutil/pull/190.patch; 
          sha256 = "c0618a319eb0c9a6efe9c72db59338232b235079042ccf77b1d690f64f735a42";
        })
      ];
    }));
  };

  environment.systemPackages = [ pkgs.sedutil ];

  systemd.services.sedutil-s3sleep = {
    description = "Enable S3 sleep on OPAL self-encrypting drives";
    documentation = [ "https://github.com/Drive-Trust-Alliance/sedutil/pull/190" ];
    path = [ pkgs.sedutil ];
    # Note: Generate password hash with: sedutil-cli --printPasswordHash PASSWORD /dev/nvme0n1
    script = "sedutil-cli -n -x --prepareForS3Sleep 0 ${(import ./secrets.nix).diskPasswordHash} /dev/nvme0n1";
    wantedBy = [ "multi-user.target" ];
  };

  # Sleep
  #   https://www.kernel.org/doc/html/latest/admin-guide/pm/sleep-states.html#basic-sysfs-interfaces-for-system-suspend-and-hibernation
  #   Force hybrid-sleep on suspend:
  #     - When suspending, write RAM to disk (hibernate)
  #     - When done writing hibernation image, suspend.
  environment.etc."systemd/sleep.conf".text = pkgs.lib.mkForce ''
    [Sleep]
    SuspendState=disk
    SuspendMode=suspend
  '';

  # Filesystems
  services.fstrim.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/53858a4b-8085-4d3e-966f-31dcc9176024";
      fsType = "btrfs";
      options = [ "noatime,subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/53858a4b-8085-4d3e-966f-31dcc9176024";
      fsType = "btrfs";
      options = [ "noatime,subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A890-68BC";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/475d3b05-809c-4f62-bc4a-5a1136337fcc"; }
    ];
}
