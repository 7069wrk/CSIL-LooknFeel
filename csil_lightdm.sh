#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="csil_lightdm-$timestamp.log"
### | tee -a "$output_file"

echo "Add LIGHTDM to CSI Theme..." | tee -a "$output_file"
tar_file="csi_usr.tar"
echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

sleep 5
echo "# Installing the CSI LIGHTDM login Theme..." | tee -a "$output_file"

sudo systemctl restart lightdm
