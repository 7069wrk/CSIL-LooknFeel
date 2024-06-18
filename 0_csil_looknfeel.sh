#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

#key = $(cat .passwd)
#echo $key

# create .logs folder
echo $key | sudo -S mkdir /usr/share/.logs
echo $key | sudo -S chmod 7777 /usr/share/.logs


# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/usr/share/.logs/csil-looknfeel-$timestamp.log"
### | tee -a "$output_file"

### add repositories
sudo add-apt-repository universe -y | tee -a "$output_file"
sudo add-apt-repository multiverse -y | tee -a "$output_file"
sudo add-apt-repository restricted -y | tee -a "$output_file"

#sudo add-apt-repository --remove universe
#sudo add-apt-repository --remove multiverse
#sudo add-apt-repository --remove restricted

### be sure most recent repository cache
sudo apt update

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
sudo apt install -y xfce4 xfce4-goodies gvfs-backends dbus-x11 task-xfce-desktop
#sudo apt install -y tasksel xubuntu-desktop task-xfce-desktop
sudo apt install -y figlet
sleep 5
echo "installing SLIM" | tee -a "$output_file"
sudo apt install -y slim

### git the repository
#echo $key | sudo -S git clone https://github.com/7069wrk/CSIL-LooknFeel.git

### restore to root
echo "expanding CSIL ROOT" | tee -a "$output_file"
tar_file="csi_looknfeel.tar"
echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

#bootloader
#source 0_csil-bootloader

#vortex
#source 1_csil-vortex

#login
#source 2_csil-login

#wallpapers
#source 3_csil--wallpaper

#power and security
echo "removing screen and power LOCKS" | tee -a "$output_file"
sudo -k
gsettings set org.gnome.desktop.session idle-delay 9999
gsettings set org.gnome.desktop.screensaver lock-delay 9999
gsettings set org.gnome.desktop.screensaver lock-enabled false

echo "we thing we are done now you can move on to the next step" | tee -a "$output_file"


#  mapfile -t csi_linux_themes < <(grep -vE "^\s*#|^$" csi_linux_themes.txt | sed -e 's/#.*//')
#while read theme_apps; do
#  echo "Installing::  $theme_apps..." | tee -a "$output_file"
#  echo $key | sudo -S apt install -y "$theme_apps" &>/dev/null | tee -a "$output_file"
#  echo "$theme_apps installed successfully." | tee -a "$output_file"
#done < csi_linux_themes.txt

#    sudo -k
