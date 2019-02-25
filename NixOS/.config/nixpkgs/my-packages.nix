self: super:

let
  inherit (super) callPackage fetchurl fetchFromGitHub;
in

{
  # Add ffmpeg to buildInputs to support media playback
  # https://github.com/NixOS/nixpkgs/pull/56144
  digikam = super.digikam.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ self.ffmpeg ];
  });

  # Add systemd to nativeBuildInputs to enable MPRIS
  cmus = super.cmus.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ self.systemd ];
  });

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

  # Override rawkit to a newer (unreleased) version that works with Python 3.7
  # See: https://github.com/NixOS/nixpkgs/issues/26487#issuecomment-307363295
  python = super.python.override {
    packageOverrides = pself: psuper: {
      rawkit = psuper.buildPythonPackage {
        pname = "rawkit";
        version = "git-93c3e9b";

        buildInputs = [ self.libraw pself.numpy ];

        checkInputs = [ pself.pytest pself.mock ];

        checkPhase = "py.test tests";

        src = fetchFromGitHub {
          owner = "photoshell";
          repo = "rawkit";
          rev = "93c3e9b6ad0b860081ea8c6f673fb0f021ac1497";
          sha256 = "1lxizxcds7ga27panv721fayyn67j8hliqx0hqhnc163xvkvfgp2";
        };
      };
    };
  };

  python3 = super.python3.override {
    packageOverrides = pself: psuper: {
      rawkit = psuper.buildPythonPackage {
        pname = "rawkit";
        version = "git-93c3e9b";

        buildInputs = [ self.libraw pself.numpy ];

        checkInputs = [ pself.pytest pself.mock ];

        checkPhase = "py.test tests";

        src = fetchFromGitHub {
          owner = "photoshell";
          repo = "rawkit";
          rev = "93c3e9b6ad0b860081ea8c6f673fb0f021ac1497";
          sha256 = "1lxizxcds7ga27panv721fayyn67j8hliqx0hqhnc163xvkvfgp2";
        };
      };
    };
  };

  python27Packages = super.recurseIntoAttrs (self.python.pkgs);
  python37Packages = super.recurseIntoAttrs (self.python3.pkgs);

  # nix-channel --update; nix-env -ir my-env
  my-env = super.buildEnv {
    name = "my-env";
    paths = with self; [
      # GUI Applications
      calibre
      deluge
      digikam breeze-icons # qt5.qtwayland
      gimp
      gnome-mpv
      google-chrome
      keepassxc
      kitty
      latest.firefox-nightly-bin
      libreoffice-fresh
      mpv
      nextcloud-client
      rapid-photo-downloader exiftool gst_all_1.gstreamer gst_all_1.gstreamer.dev gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good gst_all_1.gst-libav
      sxiv
      vlc

      # Gnome
      gnomeExtensions.appindicator
      gnomeExtensions.caffeine
      gnomeExtensions.topicons-plus

      # Development
      docker_compose
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
      oathToolkit
      qrencode
      ranger poppler_utils ffmpegthumbnailer imagemagick fontforge sqlite
      stow
      syncthing # TODO: Set up symlinks inside of ~/.config/systemd/user/
      xclip
      youtube-dl aria
    ];
  };
}
