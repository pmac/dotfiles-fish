# Set up Nix
#fenv source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'

# Stay in Fish after calling `nix-shell` or `nix run`
#any-nix-shell fish --info-right | source

if type -q nvim
    set -x EDITOR "nvim"
else
    set -x EDITOR "vim"
end

set -x LC_COLLATE "C"

set -x LESS "-F -g -i -M -R -S -w -X -z-4"
if command -v lesspipe.sh > /dev/null
    set -x LESSOPEN "|lesspipe.sh %s"
end

set -x LESSHISTFILE "$HOME/.local/share/less/history"
set -x HISTFILE "$HOME/.local/share/bash/history"

function add_user_path --description='Helper for modifying $PATH'
    for path in $argv
        if test -d $path; and not contains $path $fish_user_paths
            set -g fish_user_paths $fish_user_paths $path
        end
    end
end

# Ruby / Other Local Binaries
add_user_path "$HOME/bin"
add_user_path "$HOME/.local/bin"

# Rust / Cargo
add_user_path "$HOME/.cargo/bin"

# Use OpenSSL headers from Homebrew on macOS. Necessary for compiling Servo:
# https://github.com/sfackler/rust-openssl/issues/255
# https://github.com/servo/servo/issues/7930
if test (uname -s) = 'Darwin'; and type -q brew
    set -l base (brew --prefix openssl)
    if test -d $base
        set -x DEP_OPENSSL_INCLUDE "$base/include"
        set -x OPENSSL_INCLUDE_DIR "$base/include"
    end
end

# Prompt customization
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
set theme_show_exit_status "yes"

# Disable the "Welcome to fish" message...
set fish_greeting

# Use vi keybinding by default
set fish_key_bindings fish_vi_key_bindings

# virtualfish https://virtualfish.readthedocs.io/en/latest/install.html
set -x PROJECT_HOME ~/Projects
set -x VIRTUALFISH_COMPAT_ALIASES 1
eval (python3 -m virtualfish compat_aliases auto_activation projects)

function set_tmux_window_name --on-event virtualenv_did_activate
    set -x PYTHONDONTWRITEBYTECODE 1
    set -x PYTHONUNBUFFERED 1
    tmux rename-window (basename $VIRTUAL_ENV)
end

function set_tmux_window_default --on-event virtualenv_did_deactivate
    set -e PYTHONDONTWRITEBYTECODE
    set -e PYTHONUNBUFFERED
    tmux set-window-option automatic-rename "on" 1>/dev/null
end

source ~/.config/fish/aliases.fish
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/pmac/google-cloud-sdk/path.fish.inc' ]; . '/Users/pmac/google-cloud-sdk/path.fish.inc'; end
