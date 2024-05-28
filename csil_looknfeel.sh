#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/tmp/csil_themes-$timestamp.log"
### | tee -a "$output_file"

#./restore_backup_to_root
source restore_backup_to_root
#./update_xfce_wallpapers
source update_xfce_wallpapers
#./install_packages
source install_packages
#./reset_DNS
source reset_DNS


#cd /tmp << NOT NEEDED when cloning from github
##WHERE TO STORE BACKUP
backup_dir=$(pwd -P) #"/tmp/restorecsitheme"
###NAME OF THE BACKUP
backup_file_name="csitools_theme"
###PARSED PATH AND FILE NAME
backup_archive_path="$backup_dirct/$backup_file_name.7z"


echo "# Restore the backup of CSI Theme..."  | tee -a "$output_file"
restore_backup_to_root "$backup_dirct" "$backup_file_name"


echo "# Installing the CSI Theme..."  | tee -a "$output_file"

#echo $key | sudo -Sdos2unix csi_linux_themes.txt  | tee -a "$output_file"		
#  mapfile -t csi_linux_themes < <(grep -vE "^\s*#|^$" csi_linux_themes.txt | sed -e 's/#.*//')

while read theme_apps; do
  echo "Disabling::  $theme_apps..." | tee -a "$output_file"
  echo $key | sudo -S apt install -y "$theme_apps" &>/dev/null | tee -a "$output_file"
  echo "$theme_apps installed successfully." | tee -a "$output_file"
done < csi_linux_themes.txt


###INSTALL PACKAGES 
install_packages csi_linux_themes

###RESET DNS FOR SOME REASON
reset_DNS

###SET XFCE WALL PAPER
echo "# Configuring Background"	| tee -a "$output_file"
update_xfce_wallpapers "/opt/csitools/wallpaper/CSI-Linux-Dark.jpg"  	

###DOING GRUB STUFF
echo "Doing Grub stuff..."
echo $key | sudo -S rm /etc/alternatives/default.plymouth
echo $key | sudo -S /sbin/modprobe zfs


if echo $key | sudo -S grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then		    
    echo $key | sudo -S sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub		    
    echo "Grub is already configured for os-probe" | tee -a "$output_file"
fi
echo $key | sudo -S sed -i '/recordfail_broken=/{s/1/0/}' /etc/grub.d/00_header		
echo $key | sudo -S update-grub		
PLYMOUTH_THEME_PATH="/usr/share/plymouth/themes/vortex-ubuntu/vortex-ubuntu.plymouth"

if [ -f "$PLYMOUTH_THEME_PATH" ]; then
    echo $key | sudo -S update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth "$PLYMOUTH_THEME_PATH" 100 &> /dev/null		    
    echo $key | sudo -S update-alternatives --set default.plymouth "$PLYMOUTH_THEME_PATH"
else
    echo "Plymouth theme not found: $PLYMOUTH_THEME_PATH" | tee -a "$output_file"
fi
echo $key | sudo -S update-initramfs -u
    sudo -k
