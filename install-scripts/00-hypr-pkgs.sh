#!/bin/bash

# https://github.com/JaKooLit

# edit your packages desired here. 
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in debian repo

# add packages wanted here
Extra=(

)

# packages neeeded
hypr_package=( 
  curl
  dunst
  foot
  grim
  gvfs
  gvfs-backends
  network-manager-gnome
  pavucontrol
  playerctl
  polkit-kde-agent-1
  python3-requests
  qt5ct
  slurp
  waybar
  wget
  wl-clipboard
  wofi
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
  brightnessctl
  btop
  cava
  gnome-system-monitor
  mousepad
  mpv
  nvtop
  pamixer
  swaybg
  swayidle
  viewnior
  vim
  wlsunset
)


############## WARNING DO NOT EDIT BEYOND THIS LINE if you dont know what you are doing! ######################################
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S)_hypr-pkgs.log"

set -e

# Function for installing packages on Debian/Ubuntu
install_package() {
  # Checking if package is already installed
  if dpkg -l | grep -q -w "$1"; then
    echo -e "${OK} $1 is already installed. Skipping..."
  else
    # Package not installed
    echo -e "${NOTE} Installing $1 ..."
    if sudo apt-get install -y "$1" 2>&1 | tee -a "$LOG"; then
      echo -e "\e[1A\e[K${OK} $1 was installed."
    else
      # Something is missing, exiting to review the log
      echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log. You may need to install manually! Sorry, I have tried :("
      exit 1
    fi
  fi
}


# Installation of main components
printf "\n%s - Installing hyprland packages.... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed, please check the install.log"
    exit 1
  fi
done

# Install cliphist using go
export PATH=$PATH:/usr/local/go/bin
sudo go install go.senan.xyz/cliphist@latest 2>&1 | tee -a "$LOG"

clear
