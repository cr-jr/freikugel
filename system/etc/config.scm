(use-modules
 (gnu) (gnu system nss)
 (srfi srfi-1)
 (guix channels) (guix inferior)
 (nongnu packages linux) (nongnu system linux-initrd))

(use-service-modules
 admin pm desktop sddm xorg virtualization file-sharing syncthing ssh
 docker nix)

(use-package-modules
 curl wget file-systems linux gnome audio bootloaders certs wm xorg
 package-management version-control shells freedesktop python)

(operating-system
  ;; First, load up the main linux kernel instead of linux-libre.
  (kernel linux)
  ;; Next, load microcode and firmware.
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  ;; Then define some basic system information
  (host-name "freikugel")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout (keyboard-layout "us"))

  ;; Next, define my devices and their mount points. I configured my system
  ;; with distinct "BOOT", "ROOT", and "HOME" partitions. Referred to by
  ;; their explicit UUIDs.
  (file-systems
   (append
    (list
     (file-system
       (device (uuid "FE80-BF31" 'fat))
       (mount-point "/boot/efi")
       (type "vfat"))
     (file-system
       (device (uuid "4459083c-f870-400f-9d4f-49331356f7d3"))
       (mount-point "/")
       (type "ext4"))
     (file-system
       (device (uuid "35283795-76c0-415c-8083-d9de4c69ea62"))
       (mount-point "/home")
       (type "ext4")))
    %base-file-systems))

  ;; My system also defines a partition used for swap space, labeled "SWAP".
  (swap-devices (list (uuid "7cf9340f-fabb-4307-8b43-a323c6590b01")))

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
  (services
   (cons*
    (service unattended-upgrade-service-type)
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
              (alt-speed-time-begin (* 60 10)) ; 10:00 am
              (alt-speed-time-end (* 60 (+ 12 4))))) ; 4:00 pm
    (service syncthing-service-type
       (syncthing-configuration (user "cr-jr")))
    (service openssh-service-type)
    (service singularity-service-type)
    (service nix-service-type)
    (modify-services %desktop-services
      (delete gdm-service-type))))

  ;; Setup base packages for system functionality
  (packages
   (append
    (list
     git curl wget exfat-utils fuse-exfat stow nss-certs gvfs ntfs-3g
     udiskie fish nix sway python)
    %base-packages))

  ;; Create my username: cr-jr
  (users
   (cons
    (user-account
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
