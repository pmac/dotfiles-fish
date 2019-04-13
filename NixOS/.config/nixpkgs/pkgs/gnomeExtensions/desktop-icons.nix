{ stdenv, fetchFromGitLab, meson, ninja, python3, glib }:

stdenv.mkDerivation rec {
  name = "gnome-shell-extension-desktop-icons-${version}";
  version = "19.01.1";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World%2FShellExtensions";
    repo = "desktop-icons";
    rev = "19.01.1";
    sha256 = "03ckn231dwnkda31m722wfav30q0zrkwvv8jh3ndfkzk24dl7s1l";
  };

  nativeBuildInputs = [ meson ninja python3 glib ];

  prePatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  meta = with stdenv.lib; {
    description = "Display desktop icons in GNOME";
    license = licenses.gpl3;
    maintainers = with maintainers; [ callahad ];
    homepage = https://gitlab.gnome.org/World/ShellExtensions/desktop-icons;
  };
}
