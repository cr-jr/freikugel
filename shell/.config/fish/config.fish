# Activate default profile
bass source $GUIX_PROFILE/etc/profile

# Activate extra profiles
bass source $GUIX_EXTRA_PROFILES/dev/dev/etc/profile
bass source $GUIX_EXTRA_PROFILES/desktop/desktop/etc/profile
bass source $GUIX_EXTRA_PROFILES/addons/addons/etc/profile

# Setup Nix profile
bass source /run/current-system/profile/etc/profile.d/nix.sh

# Launch the starship
starship init fish | source

# Activate ssh agent
fish_ssh_agent

# Autoload TTY theme on login
bass source $HOME/.cache/wal/colors-tty.sh
