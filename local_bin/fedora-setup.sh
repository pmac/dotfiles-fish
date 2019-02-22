#!/usr/bin/bash

# === ThinkPad X1 Carbon 5th Generation (X1C5) with Fedora 28 ===

# BIOS:
# - Disable AMT and CompuTrace
# - Enable VT-x and VT-d

# Partitioning
# - Set Swap to 1.5x RAM size for hibernation

# Gnome Shell Extensions
# - (K)StatusNotifierItem/AppIndicator Support https://extensions.gnome.org/extension/615/appindicator-support/
# - AlternateTab https://extensions.gnome.org/extension/15/alternatetab/
# - Caffeine https://extensions.gnome.org/extension/517/caffeine/
# - Disable workspace switch animation https://extensions.gnome.org/extension/1328/disable-workspace-switch-animation/
# - Expand workspaces switcher https://extensions.gnome.org/extension/1351/show-workspaces/
# - Syncthing indicator https://extensions.gnome.org/extension/989/syncthing-icon/
# - WindowOverlay Icons https://extensions.gnome.org/extension/302/windowoverlay-icons/

# Gnome Shell Customization
#     dconf write /org/gnome/desktop/interface/show-battery-percentage true

# Rust / Rustup / Etc.
#     RUSTUP="${HOME}/.cargo/bin/rustup"
#     if ! command -v $RUSTUP > /dev/null 2>&1; then
#       curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --default-toolchain nightly
#       $RUSTUP toolchain install stable
#       $RUSTUP component add --toolchain nightly rls-preview rustfmt-preview rust-analysis rust-src
#       $RUSTUP component add --toolchain stable rls-preview rustfmt-preview rust-analysis rust-src
#       for package in ripgrep fd-find clippy; do
#           $RUSTUP run nightly cargo install $package
#       done
#     fi 

# Syncthing
#     systemctl --user enable syncthing.service
#     systemctl --user start syncthing.service

# Firefox Nightly
#     pushd $(mktemp -d)
#     curl -L 'https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US' | tar xjvf -
#     mv ./firefox /opt/
#     chown -R root:wheel /opt/firefox
#     chmod -R g+w /opt/firefox
#     find /opt/firefox -type d -exec chmod g+s {} \;
#     mkdir -p /usr/local/share/icons/hicolor/128x128/apps/
#     ln -s /opt/firefox/browser/chrome/icons/default/default128.png /usr/local/share/icons/hicolor/128x128/apps/nightly.png
#     ln -s /opt/firefox/firefox /usr/local/bin/nightly
#     sed -e 's/Firefox/Nightly/' -e 's/Exec=firefox/Exec=\/opt\/firefox\/firefox --class Nightly/' -e 's/Icon=firefox/Icon=nightly/' -e 's/Actions=.*/&profile-manager;/' /usr/share/applications/firefox.desktop > /usr/local/share/applications/nightly.desktop
#     echo -e "[Desktop Action profile-manager]\nName=Open the Profile Manager\nExec=/opt/firefox/firefox --class Nightly --new-instance --ProfileManager" >> /usr/local/share/applications/nightly.desktop
#     popd

# Thunderbird Add-ons
# - Enigmail https://enigmail.net/
# - SortPref https://addons.mozilla.org/en-US/thunderbird/addon/sortpref/

# Binaries to install manually:
# - devd: https://github.com/cortesi/devd
# - hugo: https://github.com/spf13/hugo
# - restic: https://github.com/restic/restic

# Fonts to install manually:
# - Monoid (Without Ligatures) http://larsenwork.com/monoid/

# Other programs / things to install manually:
# - Bliss https://www.blisshq.com/

log() {
     printf "\33[1m---> $*\33[0m\n"; 
}

copr() {
    if ! dnf -C repolist 2>&1 | grep -q "${1//\//-}"; then
        log "Enabling COPR $1"
        dnf -y copr enable $1
    fi
}

reporpm() {
    if ! dnf -C repolist 2>&1 | grep -q "$1"; then
        log "Enabling repo for $1"
        dnf -y install $2
    fi
}

repourl() {
    if ! dnf -C repolist 2>&1 | grep -q "$1"; then
        log "Enabling repo for $1"
        dnf -y config-manager --add-repo $2
    fi
}

repomanual() {
    if ! dnf -C repolist 2>&1 | grep -q "$1"; then
        log "Enabling repo for $1"
    echo -e "[$1]\nname=$2\nbaseurl=$3\nenabled=1\ngpgcheck=1\ngpgkey=$4" > "/etc/yum.repos.d/$1.repo"
    fi
}

REMOVE=(
    aajohan-comfortaa-fonts
    anaconda
    evolution
    fedora-productimg-workstation
    fedora-user-agent-chrome
    gnome-classic-session
    gnome-boxes
    gnome-getting-started-docs
    gnome-shell-extension-background-logo
    hyperv-daemons
    ibus-typing-booster
    julietaula-montserrat-fonts
    memtest86+
    mlocate
)

log "Removing unwanted packages"
dnf -C -y remove "${REMOVE[@]}"

# Base repos
INSTALL=(
    ImageMagick
    adobe-source-{code,sans,serif}-pro-fonts
    android-tools
    ansible
    aria2
    atool
    autoconf
    automake
    calibre
    ccache
    chrome-gnome-shell
    cloc
    cmake
    ctags
    dbus-devel
    dconf-editor
    deluge-gtk
    discount
    electrum
    elfutils
    expat-devel
    fish
    flac
    fontconfig-devel
    freetype-devel
    gcc{,-c++}
    gdb
    gimp
    git
    gitg
    glibc.i686 # For Brother printer drivers
    gnome-terminal-nautilus
    gnome-tweak-tool
    google-{roboto,noto-sans,noto-emoji-color}-fonts
    graphviz
    gstreamer1-plugins-bad-free-extras
    htop
    inkscape
    iotop
    jq
    keepassxc
    libtool
    libxml2-devel
    ltrace
    mercurial
    mesa-libGL{,U}-devel
    nasm
    {python2-,python3-,}neovim
    python{2,3}-msgpack
    nodejs
    oathtool
    open-sans-fonts
    openssl-devel
    powertop
    python2-{inotify,musicbrainzngs,paho-mqtt,virtualenv,zeitgeist}
    qrencode
    quodlibet
    retext
    rpm-build
    rpmdevtools
    strace
    sqlite
    syncthing
    task
    thunderbird
    tidy
    tig
    tmux
    urlview
    valgrind
    xclip
    xsel
    ykpers
    youtube-dl
)


# RPMFusion
reporpm rpmfusion-free https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
reporpm rpmfusion-nonfree https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
INSTALL+=(ffmpeg-libs gstreamer1-libav fuse-exfat)

# Google Chrome
reporpm google-chrome https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
INSTALL+=(google-chrome-stable)

# Visual Studio Code
if ! rpm -qa gpg-pubkey --qf "%{packager}\n" 2>&1 | grep -q "<gpgsecurity@microsoft.com>"; then
    log "Importing Microsoft's public key"
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
fi
repomanual vscode "Visual Studio Code" "https://packages.microsoft.com/yumrepos/vscode" "https://packages.microsoft.com/keys/microsoft.asc"
INSTALL+=(code)

# Docker
repourl docker-ce-stable https://download.docker.com/linux/fedora/docker-ce.repo
INSTALL+=(docker-ce)

# Kitty Terminal
copr gagbo/kitty-latest
INSTALL+=(kitty)

# Pulseaudio-DLNA
#copr cygn/pulseaudio-dlna
#INSTALL+=(pulseaudio-dlna)

# -- Install Everything --
log "Installing requested packages"
dnf -y install "${INSTALL[@]}"
