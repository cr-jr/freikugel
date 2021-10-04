;; This manifest contains the guix packages needed for my desktop
;; environment to function.

(specifications->manifest
 '("glib:bin" ;; needed for gsettings command
   "gsettings-desktop-schemas"
   "qtwayland"
   "egl-wayland"
   "gnome-themes-standard"
   "gnome-themes-extra"
   "adwaita-icon-theme"
   "font-victor-mono"
   "font-google-noto"
   "font-awesome"
   "mako"
   "kitty"
   "mpd"
   "mpd-mpc"
   "pipewire@0.3"
   "kanshi"
   "dex"
   "wl-clipboard"
   "waybar"
   "wofi"))
