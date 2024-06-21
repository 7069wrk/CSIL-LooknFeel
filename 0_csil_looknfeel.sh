#!/bin/bash

# GET SUDO
#echo "Please enter your sudo password:"
#read -s key

# Password file path
password_file=".passwd"

# Read password securely (avoid storing in script)
if [[ -f "$password_file" ]]; then
  # Read first line of password file (assuming password is on the first line)
  key=$(head -n 1 "$password_file")
  echo $key
else
  echo "Password file not found: $password_file"
  exit 1  # Script exits with error (no password)
fi

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="csil-looknfeel-$timestamp.log"
touch "$output_file"
#echo $key | sudo -S chmod 7777 "$output_file"
### | tee -a "$output_file"
#sudo -S touch "$output_file"

### add repositories
echo "add UNIVERSE" | tee -a "$output_file"
sudo add-apt-repository universe -y 
echo "add MULTIVERSE" | tee -a "$output_file"
sudo add-apt-repository multiverse -y
echo "add RESTRICTED" | tee -a "$output_file"
sudo add-apt-repository restricted -y

#sudo add-apt-repository --remove universe
#sudo add-apt-repository --remove multiverse
#sudo add-apt-repository --remove restricted

### be sure most recent repository cache
#sudo apt update

### install build dependencies
echo "Installing VM TOOLS" | tee -a "$output_file"
sudo apt install -y open-vm-tools open-vm-tools-desktop
echo "installing PYTHON STUFF" | tee -a "$output_file"
sudo apt install -y python3 python3-pip python3-venv python3-update-manager
echo "installing FILE TRANSPORTATION" | tee -a "$output_file"
sudo apt install -y git curl wget
echo "installing COMPRESSION UTILITIES" | tee -a "$output_file"
sudo apt install -y p7zip-full p7zip-rar zip
echo "installing UTILS" | tee -a "$output_file"
sudo apt install -y aria2 bpytop yad zenity dos2unix
sleep 5
echo "installing DESKTOP TRANSFORMATIONS" | tee -a "$output_file"
#sudo apt install -y xfce4 xfce4-goodies gvfs-backends dbus-x11 task-xfce-desktop
#sudo apt install -y tasksel xubuntu-desktop task-xfce-desktop
sudo apt-get install -y xfce4 xfce4-goodies gvfs-backends dbus-x11 task-xfce-desktop --no-install-recommends
### XFCE minimalist install
#sudo -S apt install -y libxfce4ui-utils \
#    thunar \
#    xfce4-appfinder \
#    xfce4-panel \
#    xfce4-session \
#    xfce4-settings \
#    xfce4-terminal \
#    xfconf \
#    xfdesktop4 \
#    xfwm4 \
#    xinit \
#    xfce4-goodies \
#    dbus-x11 \
#    task-xfce-desktop
sudo apt install -y dmz-cursor-theme \
elementary-xfce-icon-theme \
famfamfam-flag-png \
fonts-dejavu-core \
fonts-freefont-ttf \
fonts-noto-hinted \
fonts-opensymbol \
fonts-symbola \
fonts-ubuntu \
greybird-gtk-theme \
plymouth-theme-spinner \
plymouth-theme-ubuntu-text

XDG_CURRENT_DESKTOP="XFCE"

sudo -S apt install -y figlet
sleep 5
echo "installing SLIM" | tee -a "$output_file"
sudo -S apt install -y slim

### git the repository
#echo $key | sudo -S git clone https://github.com/7069wrk/CSIL-LooknFeel.git

### restore to root
echo "expanding CSIL ROOT" | tee -a "$output_file"
tar_file="csi_looknfeel.tar"
echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

#bootloader
echo "Running BOOTLOADER script"
source 1_csil_bootloader
#1_csil_bootloader

#vortex
echo "Running VORTEX script"
source 2_csil_vortex
#2_csil_vortex

#login
echo "Running SLIM script"
source 3_csil_slim
#3_csil_slim

#wallpapers
echo "Running WALLPAPER script"
source 4_csil_wallpaper
#4_csil_wallpaper

#terminal
echo "Running the TERMINAL script"
source 5_csil_terminal
#5_csil_terminal

#power and security
echo "removing screen and power LOCKS" | tee -a "$output_file"
sudo -k
gsettings set org.gnome.desktop.session idle-delay 9999
gsettings set org.gnome.desktop.screensaver lock-delay 9999
gsettings set org.gnome.desktop.screensaver lock-enabled false

echo "we THINK we are done. REBOOT to find out" | tee -a "$output_file"

