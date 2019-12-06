{ stdenv, fetchFromGitLab, meson, ninja, python3, glib }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-desktop-icons-${version}";
  version = "19.10.2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World%2FShellExtensions";
    repo = "desktop-icons";
    rev = "19.10.2";
    sha256 = "05iylydryfq61kr1zkdaz9bw0q6fm227liabz0xdfcb0iq8bxfa2";
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
