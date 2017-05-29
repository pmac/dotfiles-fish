#!/bin/sh

# --- Functions ---
# Check if any existing physical directories would be clobbered
check() {
    if [ ! -d "$2" ]; then
        echo "Creating directory: $2"
        mkdir -p "$2"
    fi

    for file in $1; do
        target="$2/$(basename "$file")"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            if [ "$CONFLICTS" -eq 0 ]; then
                echo "Error: Please remove the following files / directories:"
                CONFLICTS=1
            fi
            echo "    $target"
        fi
    done
}

# Link configuration files
link() {
    for file in $1; do
        target="$2/$(basename "$file")"
        if [ -L "$target" ]; then
            # Replace symlinks without confirmation
            lnopts="-vsnf"
        else
            # Prompt the user when replacing real files
            lnopts="-vsni"
        fi
        ln $lnopts "${PWD}/$file" "$target"
    done
}

# --- Main Script ---
OLDPWD="$PWD"
cd "$(dirname "$0")" || exit 2

CONFLICTS=0
check "dotfiles/.[A-z]*" "${HOME}"
check "xdg_config_home/*" "${XDG_CONFIG_HOME:=$HOME/.config}"
check "local_bin/*" "${HOME}/.local/bin"

if [ "$CONFLICTS" -ne 0 ]; then
    echo "Exiting"
    cd "$OLDPWD" || exit 2
    exit 1
fi

link "dotfiles/.[A-z]*" "${HOME}"
link "xdg_config_home/*" "${XDG_CONFIG_HOME:=$HOME/.config}"
link "local_bin/*" "${HOME}/.local/bin"

cd "$OLDPWD" || exit 2
