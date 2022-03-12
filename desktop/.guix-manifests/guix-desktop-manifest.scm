;; This manifest contains the guix packages needed for my desktop
;; environment to function.

(specifications->manifest
 '("glib:bin" ;; needed for gsettings command
   "glibc-locales"
   "gsettings-desktop-schemas"
   "qtwayland"
   "egl-wayland"
   "gnome-themes-standard"
   "gnome-themes-extra"
   "gnome-settings-daemon"
   "adwaita-icon-theme"
   "font-google-noto"
   "font-awesome"
   "grim"
   "slurp"
   "mako"
   "kitty"
   "mpd"
   "mpd-mpc"
   "pulseaudio" ;; so I can check up on pipewire
   "pipewire@0.3"
   "wireplumber"
   "kanshi"
   "dex"
   "wl-clipboard"
   "waybar"
   "syncthing"
   "wofi"))
