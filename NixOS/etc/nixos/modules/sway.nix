{ ... }:

{
  # Sway Window Manager
  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export XDG_SESSION_TYPE=wayland
      export KITTY_ENABLE_WAYLAND=1
      export GDK_BACKEND=wayland
      export MOZ_ENABLE_WAYLAND=1
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$EGL_LD_PATH"
    '';
  };
}
