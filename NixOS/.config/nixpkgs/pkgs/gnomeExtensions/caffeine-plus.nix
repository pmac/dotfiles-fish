{ stdenv, fetchFromGitHub, glib, gettext, bash }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-caffeine-plus-${version}";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "qunxyz";
    repo = "gnome-shell-extension-caffeine";
    rev = "v${version}";
    sha256 = "167igbg93asg8rgwavdl5f575555s0nnl10728qdc6pwybw6ma3z";
  };

  uuid = "caffeine-plus@patapon.info";

  nativeBuildInputs = [
    glib gettext
  ];

  buildPhase = ''
    ${bash}/bin/bash ./update-locale.sh
    glib-compile-schemas --strict --targetdir=caffeine-plus@patapon.info/schemas/ caffeine-plus@patapon.info/schemas
  '';

  installPhase = ''
    mkdir -p $out/share/gnome-shell/extensions
    cp -r ${uuid} $out/share/gnome-shell/extensions
  '';

  meta = with stdenv.lib; {
    description = "Fill the cup to inhibit auto suspend and screensaver";
    license = licenses.gpl2;
    maintainers = with maintainers; [ callahad ];
    homepage = https://github.com/qunxyz/gnome-shell-extension-caffeine;
  };
}
