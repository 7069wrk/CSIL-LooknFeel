ho#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/tmp/csil_themes-$timestamp.log"
### | tee -a "$output_file"

restore_backup_to_root() {
    echo $key | sudo -S sleep 1
    sudo -k

    ###VARIABLES ARE PASSED FROM SH AS
    ###restore_backup_to_root "$backup_dirct" "$backup_file_namect"
    local b_dir=$1
    local b_file_name=$2
    local b_path="$backup_dir/$backup_file_name.7z"

    echo "Restoring CSI Tools backup..."
    # Extract the .7z file safely and ensure files are overwritten without prompting
    if ! echo $key | sudo -S 7z x -aoa "$b_file_name.7z"; then
        echo "Failed to extract $b_path. Please check the file and try again." | tee -a "$output_file"
        return 1  # Exit the function with an error status
    fi

    local tar_file="$b_file_name.tar"
    if [ -f "$tar_file" ]; then
        echo "Restoring backup from tar file..."  | tee -a "$output_file"
        # Extract the tar file and ensure files are overwritten without prompting
        if ! echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /; then
            echo "Failed to restore from $tar_file. Please check the archive and try again." | tee -a "$output_file"
            return 1  # Exit the function with an error status
        fi
        echo "Backup restored successfully."  | tee -a "$output_file"
        echo $key | sudo -S rm "$tar_file"  | tee -a "$output_file"
    else
        echo "Backup .tar file not found. Please check the archive path and try again." | tee -a "$output_file"
        return 1  # Exit the function with an error status
    fi
    return 0  # Successfully completed the function
}

update_xfce_wallpapers() {
    local wallpaper_path="$1"  # Use the first argument as the wallpaper path
    if [[ -z "$wallpaper_path" ]]; then
        echo "Usage: update_xfce_wallpapers /path/to/your/wallpaper.jpg" | tee -a "$output_file"
        return 1  # Exit the function if no wallpaper path is provided
    fi
    if [ ! -f "$wallpaper_path" ]; then
        echo "The specified wallpaper file does not exist: $wallpaper_path" | tee -a "$output_file"
        return 1  # Exit the function if the wallpaper file doesn't exist
    fi
    screens=$(xfconf-query -c xfce4-desktop -l | grep -Eo 'screen[^/]+' | uniq)
    for screen in $screens; do
        monitors=$(xfconf-query -c xfce4-desktop -l | grep "${screen}/" | grep -Eo 'monitor[^/]+' | uniq)
        for monitor in $monitors; do
            workspaces=$(xfconf-query -c xfce4-desktop -l | grep "${screen}/${monitor}/" | grep -Eo 'workspace[^/]+' | uniq)
            for workspace in $workspaces; do
                # Construct the property path
                property_path="/backdrop/${screen}/${monitor}/${workspace}/last-image"
                echo "Updating wallpaper for ${property_path} to ${wallpaper_path}"
                xfconf-query -c xfce4-desktop -p "${property_path}" -n -t string -s "${wallpaper_path}"
            done
        done
    done
}

install_packages() {
  local -n packages=$1
  local newpackages=()
  local already_installed=0
  local installed=0
  local failed=0
  local total_packages=${#packages[@]}
  local current_package=0
  
  echo "Checking which packages need installation..." | tee -a "$output_file"

  # Pre-check installed status to avoid unnecessary operations
  for package in "${packages[@]}"; do
      let current_package++
      if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
          # echo "[$current_package/$total_packages] Package $package is already installed, skipping."
          ((already_installed++))
      else
          newpackages+=("$package")
      fi
  done

  echo "Out of $total_packages packages, $already_installed are already installed." | tee -a "$output_file"
  
  local new_total=${#newpackages[@]}
  if [ "$new_total" -eq 0 ]; then
      echo "No new packages to install."
      return
  fi

  echo "Starting installation of $new_total new packages..." | tee -a "$output_file"
  current_package=0

  for package in "${newpackages[@]}"; do
      let current_package++
      echo -n "[$current_package/$new_total] Installing $package... " | tee -a "$output_file"
echo $key | sudo -S apt install --fix-broken
      if echo $key | sudo -S -E DEBIAN_FRONTEND=noninteractive apt-get install -yq --assume-yes "$package"; then
          echo "SUCCESS" | tee -a "$output_file"
          ((installed++))
      else
          echo "FAILED" | tee -a "$output_file"
          ((failed++))
          echo "$package" | tee -a "$output_file"
      fi
  done

  echo -e "\nInstallation complete." | tee -a "$output_file"
  echo "Summary: $already_installed skipped, $installed installed, $failed failed." | tee -a "$output_file"
  if [ $failed -gt 0 ]; then
      echo "Details of failed installations have been logged to /opt/csitools/apt-failed.txt." | tee -a "$output_file"
  fi
}

reset_DNS() {
    check_connection() {
        ping -c 1 8.8.8.8 >/dev/null
    }
    check_dns() {
        ping -c 1 google.com >/dev/null
    }
    echo "# Checking and updating /etc/resolv.conf" | tee -a "$output_file"
    echo $key | sudo -S mv /etc/resolv.conf /etc/resolv.conf.bak
    echo "nameserver 127.0.0.53" | sudo tee /etc/resolv.conf > /dev/null
    echo "nameserver 127.3.2.1" | sudo tee -a /etc/resolv.conf > /dev/null
    printf "\nDNS nameservers updated.\n"
    echo $key | sudo -S systemctl restart systemd-resolved
    while ! systemctl is-active --quiet systemd-resolved; do
        echo "Waiting for systemd-resolved to restart..." | tee -a "$output_file"
        sleep 1
    done
    echo "systemd-resolved restarted successfully." | tee -a "$output_file"

    max_retries=5
    retry_count=0

    while [[ $retry_count -lt $max_retries ]]; do
        if check_connection; then
            echo "Internet connection is working." | tee -a "$output_file"
            if ! check_dns; then
                echo "The internet is working, but DNS is not working. Please check your resolv.conf file" | tee -a "$output_file"
                ((retry_count++))
            else
                break
            fi
        else
            echo "Internet connection is not working. Please check your network." | tee -a "$output_file"
            ((retry_count++))
        fi
    done
    if [[ $retry_count -eq $max_retries ]]; then
        echo "Maximum retries reached. Exiting." | tee -a "$output_file"
    fi
    echo $key | sudo -S sleep 1
    sudo -k
}


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
echo $key | sudo -Sdos2unix csi_linux_themes.txt  | tee -a "$output_file"		
  mapfile -t csi_linux_themes < <(grep -vE "^\s*#|^$" csi_linux_themes.txt | sed -e 's/#.*//')
echo "$csi_linux_themes"

install_packages csi_linux_themes
  # installed_packages_desc csi_linux_themes
reset_DNS
echo "# Configuring Background"	| tee -a "$output_file"
update_xfce_wallpapers "/opt/csitools/wallpaper/CSI-Linux-Dark.jpg"  	
  echo "Doing Grub stuff..."
    ### COMMAND NOT FOUND - another dependency        
    echo $key | sudo -S "/usr/sbin/modprobe zfs"

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
