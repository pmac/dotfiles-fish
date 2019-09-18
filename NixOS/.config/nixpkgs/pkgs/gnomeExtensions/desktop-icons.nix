{ stdenv, fetchFromGitLab, meson, ninja, python3, glib }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-desktop-icons-${version}";
  version = "2019-04-03"; # Several commits beyond version 19.01.1

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World%2FShellExtensions";
    repo = "desktop-icons";
    rev = "b0cfb3d4ff5d9298a5aafb1ef6bcd39512fc64b0";
    sha256 = "1b7vnpsp112k2nchgqvphwv5bffqrw63ywib4qg4p01yvhapns92";
  };

  nativeBuildInputs = [ meson ninja python3 glib ];

  prePatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  patches = [
    ./fix-desktop-icons.patch
  ];

  postPatch = ''
    substituteInPlace prefs.js \
      --subst-var-by gschemasDir "${placeholder "out"}/share/gsettings-schemas/${name}/glib-2.0/schemas"
  '';

  meta = with stdenv.lib; {
    description = "Display desktop icons in GNOME";
    license = licenses.gpl3;
    maintainers = with maintainers; [ callahad ];
    homepage = https://gitlab.gnome.org/World/ShellExtensions/desktop-icons;
  };
}
