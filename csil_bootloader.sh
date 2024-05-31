#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/tmp/csil_themes-$timestamp.log"
### | tee -a "$output_file"

echo "# Restore the backup of CSI Theme..."  | tee -a "$output_file"
echo $key | sudo -S tar --overwrite -xpf "csi_boot.tar" -C /;

sleep 5
echo "# Installing the CSI BOOTLOADER Theme..."  | tee -a "$output_file"


###DOING GRUB STUFF
echo "Doing Grub stuff..."
###folder where the grub file is /etc/default

if echo $key | sudo -S grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then		    
    echo $key | sudo -S sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub		    
    echo "Grub is already configured for os-probe" | tee -a "$output_file"
fi

if ! echo $key | sudo -S grep -q "GRUB_THEME=/boot/grub/themes/csilinux1/theme.txt" /etc/default/grub; then		
  echo $key | sudo -S sed -i '$a GRUB_THEME=/boot/grub/themes/csilinux1/theme.txt' /etc/default/grub
  echo "Grub is already configured for CSI Theme" | tee -a "$output_file"
fi

###SEARCHES for the timeout and replaces the time with 5
echo $key | sudo -S sed -i 's/GRUB TIMEOUT="[^"]*"/GRUB TIMEOUT="5"/' /etc/default/grub

echo $key | sudo -S sed -i '$a GRUB_GFXMODE=1024x768x16' /etc/default/grub
echo $key | sudo -S sed -i '$a GRUB_GFXPAYLOAD_LINUX=keep' /etc/default/grub
#GRUB_GFXMODE="1024x768x16"
#GRUB_GFXPAYLOAD_LINUX="keep"



###SEARCHES for the command and replaces all `1` with `0`
echo $key | sudo -S sed -i '/recordfail_broken=/{s/1/0/}' /etc/grub.d/00_header

###LINES that need to be written or can be - the INIT_TUNE is not required.
#GRUB_DISABLE_OS_PROBER="false"
#GRUB_GFXMODE="1024x768x16"
#GRUB_GFXPAYLOAD_LINUX="keep"
##GRUB_INIT_TUNE="480 440 1"
#GRUB_THEME="/boot/grub/themes/csilinux1/theme.txt"

sleep 5
echo $key | sudo -S update-grub	
