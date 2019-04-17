{ stdenv, fetchFromGitHub, glib, zip, unzip, gnome3, systemd }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-syncthing-${version}";
  version = "2019-04-06";

  src = fetchFromGitHub {
    owner = "jaystrictor";
    repo = "gnome-shell-extension-syncthing";
    rev = "2396625ea5d1ca9d5b25bf22cff7e4593a0e472e";
    sha256 = "1akgy9i1w436azndfz55kixbr2z4kcgsg2ajf4q62bd94yqk69i9";
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
