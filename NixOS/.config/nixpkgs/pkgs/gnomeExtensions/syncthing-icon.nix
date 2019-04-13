{ stdenv, fetchFromGitHub, glib, zip, unzip, gnome3, systemd }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-syncthing-${version}";
  version = "2019-02-18";

  src = fetchFromGitHub {
    owner = "jaystrictor";
    repo = "gnome-shell-extension-syncthing";
    rev = "d90db936371fa9253924c6e726d5614131698389";
    sha256 = "0ilhvcjarf4rsa7plpv6kp919j0jw9swyaydfrla08lh67za4h5m";
  };

  nativeBuildInputs = [ glib zip unzip ];
  buildInputs = [ gnome3.gjs systemd ];

  prePatch = ''
    substituteInPlace src/systemd.js \
      --replace "/bin/systemctl" "${systemd}/bin/systemctl"
    substituteInPlace src/extension.js \
      --replace "gjs" "${gnome3.gjs}/bin/gjs"
  '';

  # Note, this still doesn't work as gjs / gnome3 doesn't depend on webkitgtk

  buildPhase = ''
    ./build.sh
  '';

  installPhase = ''
    substituteInPlace install.sh --replace '$HOME/.local/' '$out/'
    ./install.sh
  '';

  meta = with stdenv.lib; {
    description = "Display SyncThing status icon in top bar";
    license = licenses.gpl3;
    maintainers = with maintainers; [ callahad ];
    homepage = https://github.com/jaystrictor/gnome-shell-extension-syncthing;
  };
}
