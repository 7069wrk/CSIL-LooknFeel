#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/tmp/csil_themes-$timestamp.log"
### | tee -a "$output_file"

#cd /tmp << NOT NEEDED when cloning from github
##WHERE TO STORE BACKUP
backup_dir=$(pwd -P)
###NAME OF THE BACKUP
backup_file_name="csi_boot"
###PARSED PATH AND FILE NAME
tar_file="$backup_dirct/$backup_file_name.tar"  ###csi_boot.tar


echo "# Restore the backup of CSI Theme..."  | tee -a "$output_file"
#restore_backup_to_root "$backup_dirct" "$backup_file_name"
echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /


echo "# Installing the CSI BOOTLOADER Theme..."  | tee -a "$output_file"


###DOING GRUB STUFF
echo "Doing Grub stuff..."
###folder where the grub file is /etc/default

if echo $key | sudo -S grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then		    
    echo $key | sudo -S sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub		    
    echo "Grub is already configured for os-probe" | tee -a "$output_file"
fi
echo $key | sudo -S sed -i '$a GRUB_THEME=\"/boot/grub/themes/csilinux1/theme.txt\"' /etc/default/grub
echo $key | sudo -S sed -i '/recordfail_broken=/{s/1/0/}' /etc/grub.d/00_header		

###LINES that need to be written or can be - the INIT_TUNE is not required.
#GRUB_DISABLE_OS_PROBER="false"
##GRUB_INIT_TUNE="480 440 1"
#GRUB_THEME="/boot/grub/themes/csilinux1/theme.txt"

echo $key | sudo -S update-grub	
