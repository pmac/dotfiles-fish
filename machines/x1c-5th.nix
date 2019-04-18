{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  # Host
  networking.hostName = "meta";
  time.timeZone = "Europe/Belfast";
  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  services.tlp.enable = true;

  # Hardware
  #   https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.s3tcSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
  services.xserver.useGlamor = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.tmpOnTmpfs = true;

  # Kernel
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_fbc=1" # Save an infinitesimal amount of power by compressing the framebuffer
    "i915.fastboot=1"   # Avoid modesets until we're in a graphical environment
  ];

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

    # Fix Intel VAAPI
    # See: https://github.com/NixOS/nixpkgs/pull/55976
    vaapiIntel = pkgs.vaapiIntel.overrideAttrs (oldAttrs: {
        name = "intel-vaapi-driver-git-20190211";
        version = "git-20190211";
        rev = "329975c63123610fc750241654a3bd18add75beb";

        src = pkgs.fetchFromGitHub {
            owner = "intel";
            repo = "intel-vaapi-driver";
            rev = "329975c63123610fc750241654a3bd18add75beb";
            sha256 = "10333wh2d0hvz5lxl3gjvqs71s7v9ajb0269b3bj5kbflj03v3n5";
        };
    });
  };

  environment.systemPackages = [ pkgs.sedutil ];

  systemd.services.sedutil-s3sleep = {
    description = "Enable S3 sleep on OPAL self-encrypting drives";
    documentation = [ "https://github.com/Drive-Trust-Alliance/sedutil/pull/190" ];
    path = [ pkgs.sedutil ];
    script = "sedutil-cli -n -x --prepareForS3Sleep 0 ***REMOVED*** /dev/nvme0n1";
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
  #   Note: Set "discard" option on btrfs mounts if not using fstrim service
  services.fstrim.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/96013bca-b5f2-41b5-9aef-b7332ef60c16";
      fsType = "btrfs";
      options = [ "noatime,subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/96013bca-b5f2-41b5-9aef-b7332ef60c16";
      fsType = "btrfs";
      options = [ "noatime,subvol=home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0179-3A6F";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7a723fc5-90f6-406d-9858-18f61291c9da"; }
    ];
}
