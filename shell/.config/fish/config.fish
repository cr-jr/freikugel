# Activate profiles on login, ignoring .config/guix/current
for profile in (guix package --list-profiles)
  if test $profile = "$HOME/.config/guix/current"
    echo "$profile" 1> /dev/null
  else
    set GUIX_PROFILE $profile
    bass source $profile/etc/profile
  end
end

# Setup Nix profile
bass source /run/current-system/profile/etc/profile.d/nix.sh

# Launch the starship
starship init fish | source

# Activate ssh agent
fish_ssh_agent

# Autoload TTY theme on login
bass source $HOME/.cache/wal/colors-tty.sh
