# Setup Guix user environment
set GUIX_PROFILE "$HOME/.guix-profile"
bass source $GUIX_PROFILE/etc/profile

# Setup Nix user environment
bass source /run/current-system/profile/etc/profile.d/nix.sh

# Launch the starship
starship init fish | source
