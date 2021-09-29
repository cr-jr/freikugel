;; This is the system configuration for my main machine. Since it uses
;; proprietary hardware, I need to use the nonguix channel to ensure I
;; have the correct kernel and firmware.

(use-modules
 (gnu)
 (srfi srfi-1)
 (gnu system nss)
 (nongnu packages linux)
 (nongnu system linux-initrd))

(use-service-modules
 admin pm desktop sddm xorg virtualization file-sharing syncthing ssh docker nix)

(use-package-modules
 curl
 wget
 file-systems
 linux
 gnome
 audio
 freedesktop
 emacs
 terminals
 virtualization
 admin
 bittorrent
 python
 python-xyz
 mpd
 graphics
 qt
 gtk
 kde
 cmake
 xdisorg
 fonts
 video
 web-browsers
 inkscape
 scribus
 pdf
 terminals
 bootloaders
 certs
 wm
 xorg
 package-management
 version-control
 shells)

(operating-system
  ;; First, load up the main linux kernel instead of linux-libre.
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  ;; Then define some basic system information
  (host-name "freikugel")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout (keyboard-layout "us" "intl"))

  ;; Next, define my devices and their mount points. I configured my system
  ;; with distinct "BOOT", "ROOT", and "HOME" partitions. Referred to by
  ;; their explicit UUIDs.
  (file-systems (append
                 (list (file-system
       (device (uuid "F949-2F26" 'fat))
       (mount-point "/boot/efi")
       (type "vfat"))
           (file-system
       (device (uuid "d66d6de0-4968-4bdd-9aea-18525c06dad6"))
       (mount-point "/")
       (type "ext4"))
           (file-system
       (device (uuid "29eca1a4-84b3-47f8-b9d7-088e2f963f94"))
       (mount-point "/home")
       (type "ext4")))
                 %base-file-systems))

  ;; My system also defines a partition used for swap space, labeled "SWAP".
  (swap-devices (list (uuid "55f2d49f-f4e9-4b8b-bef1-6634c2404937")))

  ;; Finally, to ensure a proper boot, my system uses the GRUB bootloader.
  ;; Note: my system is also UEFI, so it's configured accordingly. I may get
  ;; an itch to try other bootloaders, but not today.
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (keyboard-layout keyboard-layout)
    (targets '("/boot/efi"))))

  ;; Now, I initialize and configure some useful services for my daily work.
  ;; This includes a simple desktop environment with the necessary wiring.
  ;;
  ;; Unattended upgrades are a helpful way for me to stay on top of system
  ;; and package updates and not worry about whether I have the latest kit.
  (services (cons*
       (service unattended-upgrade-service-type)
       (service tlp-service-type
          (tlp-configuration
           (cpu-boost-on-ac? #t)
           (wifi-pwr-on-bat? #t)))
       (service sddm-service-type
          (sddm-configuration
           (display-server "wayland")))
       (service libvirt-service-type)
       (service virtlog-service-type)
       (service qemu-binfmt-service-type
          (qemu-binfmt-configuration
           (platforms (lookup-qemu-platforms "arm" "aarch64"))))
       (service transmission-daemon-service-type
          (transmission-daemon-configuration
           ;; Restrict RPC access
           (rpc-username "transmission")
           (rpc-password "{464b30ba31cfe83ffb5692cf78e26613f4d4b865S4sCVYvH")
           ;; Accept requests only from following hosts:
           (rpc-whitelist-enabled? #t)
           (rpc-whitelist '("::1" "127.0.0.1" "192.168.1.*"))
           ;; Limit bandwidth during work hours
           (alt-speed-down 1024) ; 1 MB/s
           (alt-speed-up 256) ; 256 KB/s

           (alt-speed-time-enabled? #t)
           (alt-speed-time-day 'weekdays)
           (alt-speed-time-begin
      (* 60 10)) ; 10:00 am
           (alt-speed-time-end
      (* 60 (+ 12 4))))) ; 4:00 pm
       (service syncthing-service-type
          (syncthing-configuration (user "cr-jr")))
       (service openssh-service-type)
       (service singularity-service-type)
       (service nix-service-type)
       (modify-services %desktop-services
               (delete gdm-service-type))))

  ;; Setup base packages for system functionality
  (packages (append (list
         ;; utilities
         git curl wget exfat-utils fuse-exfat stow nss-certs gvfs tlp
         bluez bluez-alsa ntfs-3g udiskie
         ;; editors
         emacs
         ;; terminal
         fish kitty bpytop transmission singularity python mpd-mpc ncmpcpp cmake libvterm
         ;; desktop
         sway swaybg swaylock swayidle mako waybar kanshi egl-wayland qtwayland wl-clipboard
         python-pywal pipewire wofi dex xsettingsd (list gtk+ "bin") mpd ; gtk+:bin needed for gsettings
         font-google-noto font-victor-mono font-awesome
         ;; apps
         mpv qutebrowser virt-manager nautilus krita inkscape scribus
         zathura zathura-pdf-mupdf zathura-djvu zathura-cb zathura-ps
         ;; extra packages
         nix)
        %base-packages))

  ;; Create my username: cr-jr
  (users (cons (user-account
    (name "cr-jr")
    (group "users")
    (comment "Chatman R. Jr")
    (shell (file-append fish "/bin/fish"))
    (home-directory "/home/cr-jr")
    (supplementary-groups
     '("wheel" "netdev" "kvm" "tty" "input" "lp" "audio" "video" "libvirt")))
               %base-user-accounts))

  ;; Create system groups
  (groups %base-groups)

  ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))
