self: super:

let
  inherit (super) callPackage fetchurl fetchFromGitHub;
in

{
  # Waiting on https://github.com/NixOS/nixpkgs/pull/59347
  # Commit hash ee483a6aa8c3acf4b951b7a89038077b8a615197
  rapid-photo-downloader = callPackage ./pkgs/rapid-photo-downloader/default.nix { };

  # Gnome Extensions
  gnomeExtensions = super.gnomeExtensions // {
    #caffeine-plus = callPackage ./pkgs/gnomeExtensions/caffeine-plus.nix { };
    syncthing-icon = callPackage ./pkgs/gnomeExtensions/syncthing-icon.nix { };
    desktop-icons = callPackage ./pkgs/gnomeExtensions/desktop-icons.nix { };
  };

  # Add WebP support to imlib2
  imlib2 = super.imlib2.overrideAttrs (oldAttrs: {
      src = super.fetchurl {
          url = "https://git.enlightenment.org/legacy/imlib2.git/snapshot/imlib2-1.5.1.tar.gz";
          sha256 = "1gpsd6kxa35gz2x6lc87yy2id25az42vkbcxbnm73cvaqaxvi7p2";
      };

      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ (with self; [
        automake autoconf libtool
      ]);

      buildInputs = oldAttrs.buildInputs ++ [ self.libwebp ];

      preConfigure = ''
        ./autogen.sh
      '';

      patches = (oldAttrs.patches or []) ++ [ ./pkgs/imlib2/webp.patch ];
  });

  # Update Gnome MPV (soon to be renamed Celluloid)
  gnome-mpv = super.gnome-mpv.overrideAttrs (oldAttrs: {
      name = "gnome-mpv-0.16";
      version = "0.16";

      doCheck = false;

      src = fetchFromGitHub {
          owner = "celluloid-player";
          repo = "celluloid";
          rev = "v0.16";
          sha256 = "1fj5mr1dwd07jpnigk7z85xdm6yaf7spbvf60aj3mz12m05b1b2w";
      };
  });

  # sudo nix-channel --update; nix-env -ir my-env
  my-env = super.buildEnv {
    name = "my-env";
    paths = with self; [
      # GUI Applications
      calibre
      deluge
      digikam breeze-icons # qt5.qtwayland
      flameshot
      gimp
      gnome-mpv
      google-chrome
      inkscape
      keepassxc
      kitty
      latest.firefox-nightly-bin
      libreoffice-fresh
      mpv
      nextcloud-client
      peek
      # quodlibet-full # Fails to build, https://github.com/NixOS/nixpkgs/issues/53938
      rapid-photo-downloader
      simple-scan
      slack # :-(
      sxiv
      typora
      vlc

      # Development
      docker_compose
      emacs
      gitAndTools.gitSVN
      gitAndTools.hub
      gitAndTools.tig
      gitg
      jq
      mercurial

      # Console Utilities
      cmus
      ffmpeg
      highlight
      hugo
      oathToolkit
      qrencode
      ranger poppler_utils ffmpegthumbnailer imagemagick fontforge sqlite
      stow
      syncthing # TODO: Set up symlinks inside of ~/.config/systemd/user/
      xclip
      youtube-dl aria
    ] ++ (with gnomeExtensions; [
      appindicator
      caffeine
      topicons-plus
      #caffeine-plus
      syncthing-icon
      desktop-icons
    ]);
  };
}
