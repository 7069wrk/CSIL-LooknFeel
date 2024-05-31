 |#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="csil_vortex-$timestamp.log"
### | tee -a "$output_file"

echo $key | sudo -S touch "$output_file"

echo "Add VORTEX to CSI Theme..." | tee -a "$output_file"
tar_file="csi_vortex.tar"
echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

sleep 5
echo "# Installing the CSI BOOTLOADER Theme..." | tee -a "$output_file"

###REMOVE old files to ensure that new files are accepted.
echo $key | sudo -S rm /usr/share/plymouth/themes/default.plymouth
echo $key | sudo -S rm /etc/alternatives/default.plymouth

sleep 5
# adding csil-vortex in the list of aviable themes
echo -n "updating plymouth themes alternatives   ........................   " | tee -a "$output_file"
echo $key | sudo -S update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/csil-000/csil-000.plymouth 100 &>/dev/null
echo $key | sudo -S update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/csil-001/csil-001.plymouth 100 &>/dev/null
echo $key | sudo -S update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/vortex-ubuntu/vortex-ubuntu.plymouth 100 &>/dev/null
if [ $? -gt 0 ]; then
  echo -e "\nan error occurred installing alternative in /usr/share/plymouth/themes/default.plymouth" | tee -a "$output_file"
  exit 1
fi
echo "[done]"

# setting csil-vortex as default plymouth theme;
echo -n "setting CSILinux Vortex as default plymouth theme   .................   " | tee -a "$output_file"
#echo $key | sudo -S update-alternatives --set default.plymouth /usr/share/plymouth/themes/csil-000/csil-000.plymouth  &> /dev/null ;
echo $key | sudo -S update-alternatives --set default.plymouth /usr/share/plymouth/themes/csil-001/csil-001.plymouth &>/dev/null
#echo $key | sudo -S update-alternatives --set default.plymouth /usr/share/plymouth/themes/vortex-ubuntu/vortex-ubuntu.plymouth  &> /dev/null ;
#echo $key | sudo -S update-alternatives --set default.plymouth /usr/share/plymouth/themes/csil-003/csil-003.plymouth
if [ $? -gt 0 ]; then
  echo -e "\nan error occurred setting alternative in /usr/share/plymouth/themes/default.plymouth" | tee -a "$output_file"
  exit 1
fi
echo "[done]"

#sudo update-alternatives --config default.plymouth

# updating Initial RAM File System
echo -n "updating Initial RAM File System   .............................   " | tee -a "$output_file"
echo $key | sudo -S update-initramfs -u &>/dev/null
if [ $? -gt 0 ]; then
  echo -e "\nan error occurred executing \"update-initramfs -u\"" | tee -a "$output_file"
  exit 1
fi
echo "[done]" | tee -a "$output_file"

echo "CSILinux Vortex is your plymouth theme now :)" | tee -a "$output_file"

exit 0
