#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/usr/share/.logs/csil_themes-$timestamp.log"
touch "$output_file"
### | tee -a "$output_file"

echo "# Restore the backup of CSI Theme..." | tee -a "$output_file"
#tar_file="csi_boot.tar"
#echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

sleep 5
echo "# Installing the CSI BOOTLOADER Theme..." | tee -a "$output_file"

###DOING GRUB STUFF
echo "Doing Grub stuff to /etc/default/grub..."

###SEARCHES and replaces the # on the prober line
if echo $key | sudo -S grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
  echo $key | sudo -S sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
  echo "Grub_OS_PROBE is configured" | tee -a "$output_file"
fi

###SEARCHES for menu in the string and replaces if not
if ! echo $key | sudo -S grep -q "GRUB_TIMEOUT_STYLE=menu" /etc/default/grub; then
  echo $key | sudo -S sed -i '/^GRUB_TIMEOUT_STYLE=/s/=.*/=menu/' /etc/default/grub
  echo "Grub_TIMEOUT_STYLE is configured" | tee -a "$output_file"
fi

###SEARCHES for the timeout and replaces the time with 10
if ! echo $key | sudo -S grep -q "GRUB_TIMEOUT=10" /etc/default/grub; then
  echo $key | sudo -S sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
  echo "Grub_TIMEOUT is configured" | tee -a "$output_file"
fi

#GRUB_GFXMODE="1024x768x16"
if ! echo $key | sudo -S grep -q "GRUB_GFXMODE=1024x768x16" /etc/default/grub; then
  echo $key | sudo -S sed -i '$a GRUB_GFXMODE=1024x768x16' /etc/default/grub
  echo "Grub_GFXMODE is configured" | tee -a "$output_file"
fi

#GRUB_GFXPAYLOAD_LINUX="keep"
if ! echo $key | sudo -S grep -q "GRUB_GFXPAYLOAD_LINUX=keep" /etc/default/grub; then
  echo $key | sudo -S sed -i '$a GRUB_GFXPAYLOAD_LINUX=keep' /etc/default/grub
  echo "Grub_GFXPAYLOAD is configured" | tee -a "$output_file"
fi

#GRUB_THEME=csi
if ! echo $key | sudo -S grep -q "GRUB_THEME=/boot/grub/themes/csilinux1/theme.txt" /etc/default/grub; then
  echo $key | sudo -S sed -i '$aGRUB_THEME=/boot/grub/themes/csilinux1/theme.txt' /etc/default/grub
  echo "Grub_GFXPAYLOAD is configured" | tee -a "$output_file"
fi

###SEARCHES for the command and replaces all `1` with `0`
echo $key | sudo -S sed -i '/recordfail_broken=/{s/1/0/}' /etc/grub.d/00_header

sleep 5
echo $key | sudo -S update-grub
