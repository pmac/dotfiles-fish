{ stdenv, fetchFromGitHub, glib, zip, unzip, gnome3, systemd, webkitgtk }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-syncthing-${version}";
  version = "2019-10-25";

  src = fetchFromGitHub {
    owner = "jaystrictor";
    repo = "gnome-shell-extension-syncthing";
    rev = "9ba7376028e7c269ddef18c81f44adadfe477a7e";
    sha256 = "042jsyc554rbn0rvbp3syw51cz90rqjhqp4q61cyzsff8zj9l7ky";
  };

  nativeBuildInputs = [ glib zip unzip ];
  buildInputs = [ gnome3.gjs webkitgtk systemd ];

  patches = [
    ./fix-syncthing-icon.patch
  ];

  postPatch = ''
    substituteInPlace src/systemd.js \
      --replace "/bin/systemctl" "${systemd}/bin/systemctl"
    substituteInPlace src/extension.js \
      --replace "gjs" "${gnome3.gjs}/bin/gjs"
    substituteInPlace src/webviewer.js \
      --subst-var-by webkitPath "${webkitgtk}/lib/girepository-1.0"
  '';

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
