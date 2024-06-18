#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

#key = $(cat .passwd)
#echo $key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="~/csil-looknfeel-$timestamp.log"
### | tee -a "$output_file"

### add repositories
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo add-apt-repository restricted

#sudo add-apt-repository --remove universe
#sudo add-apt-repository --remove multiverse
#sudo add-apt-repository --remove restricted

### be sure most recent repository cache
sudo apt update

### install build dependencies
echo "Installing VM TOOLS"
sudo apt install -y open-vm-tools open-vm-tools-desktop
echo "installing PYTHON STUFF"
sudo apt install -y python3 python3-pip python3-venv python3-update-manager
echo "installing FILE TRANSPORTATION"
sudo apt install -y git curl wget
echo "installing COMPRESSION UTILITIES"
sudo apt install -y p7zip-full p7zip-rar zip
echo "installing UTILS"
sudo apt install -y aria2 bpytop yad zenity dos2unix
sleep 5
echo "installing DESKTOP TRANSFORMATIONS"
sudo apt install -y xfce4 xfce4-goodies gvfs-backends dbus-x11 task-xfce-desktop
#sudo apt install -y tasksel xubuntu-desktop task-xfce-desktop
sudo apt install -y figlet
sleep 5
echo "installing SLIM"
sudo apt install -y slim

### git the repository
#echo $key | sudo -S git clone https://github.com/7069wrk/CSIL-LooknFeel.git

### restore to root
echo "expanding CSIL ROOT"
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
gsettings set org.gnome.desktop.session idle-delay 9999
gsettings set org.gnome.desktop.screensaver lock-delay 9999
gsettings set org.gnome.desktop.screensaver lock-enabled false


#cd /tmp << NOT NEEDED when cloning from github
##WHERE TO STORE BACKUP
#backup_dir=$(pwd -P) #"/tmp/restorecsitheme"
###NAME OF THE BACKUP
#backup_file_name="csitools_theme"
###PARSED PATH AND FILE NAME
#backup_archive_path="$backup_dirct/$backup_file_name.7z"


#echo "# Restore the backup of CSI Theme..."  | tee -a "$output_file"
#restore_backup_to_root "$backup_dirct" "$backup_file_name"


#echo "# Installing the CSI Theme..."  | tee -a "$output_file"

#echo $key | sudo -Sdos2unix csi_linux_themes.txt  | tee -a "$output_file"		
#  mapfile -t csi_linux_themes < <(grep -vE "^\s*#|^$" csi_linux_themes.txt | sed -e 's/#.*//')

#while read theme_apps; do
#  echo "Installing::  $theme_apps..." | tee -a "$output_file"
#  echo $key | sudo -S apt install -y "$theme_apps" &>/dev/null | tee -a "$output_file"
#  echo "$theme_apps installed successfully." | tee -a "$output_file"
#done < csi_linux_themes.txt


###INSTALL PACKAGES 
#install_packages csi_linux_themes

###RESET DNS FOR SOME REASON
#reset_DNS

###SET XFCE WALL PAPER
#echo "# Configuring Background"	| tee -a "$output_file"
#update_xfce_wallpapers "/opt/csitools/wallpaper/CSI-Linux-Dark.jpg"  	

###DOING GRUB STUFF
#echo "Doing Grub stuff..."
#echo $key | sudo -S rm /etc/alternatives/default.plymouth
#echo $key | sudo -S /sbin/modprobe zfs


#if echo $key | sudo -S grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then		    
#    echo $key | sudo -S sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub		    
#    echo "Grub is already configured for os-probe" | tee -a "$output_file"
#fi
#echo $key | sudo -S sed -i '/recordfail_broken=/{s/1/0/}' /etc/grub.d/00_header		
#echo $key | sudo -S update-grub		
#PLYMOUTH_THEME_PATH="/usr/share/plymouth/themes/csil-001/csil-001.plymouth"

#if [ -f "$PLYMOUTH_THEME_PATH" ]; then
#    echo $key | sudo -S update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth "$PLYMOUTH_THEME_PATH" 100 &> /dev/null		    
#    echo $key | sudo -S update-alternatives --set default.plymouth "$PLYMOUTH_THEME_PATH"
#else
#    echo "Plymouth theme not found: $PLYMOUTH_THEME_PATH" | tee -a "$output_file"
#fi
#echo $key | sudo -S update-initramfs -u
#    sudo -k
