#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/tmp/csil_looknfeel-$timestamp.log"
### | tee -a "$output_file"

restore_backup_to_root() {
    echo $key | sudo -S sleep 1
    sudo -k

    ###VARIABLES ARE PASSED FROM SH AS
    ###restore_backup_to_root "$backup_dirct" "$backup_file_namect"
    local backup_dir=$1
    local backup_file_name=$2
    local archive_path="$backup_dir/$backup_file_name.7z"

    echo "Restoring CSI Tools backup..."
    # Extract the .7z file safely and ensure files are overwritten without prompting
    if ! echo $key | sudo -S 7z x -aoa -o "$backup_file_name" "$archive_path"; then
        echo "Failed to extract $archive_path. Please check the file and try again." | tee -a "$output_file"
        return 1  # Exit the function with an error status
    fi

    local tar_file="$backup_dir/$backup_file_name.tar"
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
            #echo "$package" >> /opt/csitools/apt-failed.txt
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


#cd /tmp
    ##WHERE TO STORE BACKUP
    backup_dirct="CSIL-LooknFeel" #$(pwd -P)
    ###NAME OF THE BACKUP
    backup_file_namect="csitools_theme"
    ###PARSED PATH AND FILE NAME
    archive_pathct="$backup_dirct/$backup_file_namect.7z"
		
    ###SET THESE COMMANDS AS NON_INTERACTIVE
    echo "$key" | sudo -S DEBIAN_FRONTEND=noninteractive apt install aria2 -y &>/dev/null
		
    ###CREATE FOLDER FOR DOWNLOAD BY REMOVING AND RECREATING
    echo "Preparing for the CSI Theme download..."  | tee -a "$output_file"
    #echo "$key" | sudo -S rm -rf "$backup_dirct" # Remove the entire backup directory		
    #echo "$key" | sudo -S mkdir -p "$backup_dirct"
    #echo "$key" | sudo -S chmod 777 "$backup_dirct" # Set full permissions temporarily for download
		
    #echo "Downloading the CSI Theme..."  | tee -a "$output_file"
		
    #if aria2c -x3 -k1M "https://csilinux.com/downloads/$backup_file_namect.7z" -d "$backup_dirct" -o "$backup_file_namect.7z"; then
    #if [ -f "$backup_file_namect.7z" ]; then
    #  :
    #else
    #  #aria2c -x3 -k1M "https://csilinux.com/downloads/$backup_file_namect.7z" -d "$backup_dirct" -o "$backup_file_namect.7z"
    #  curl -sSL https://api.github.com/repos/7069wrk/CSIL-LooknFeel/releases/latest
    #fi
		#	echo "Download successful."  | tee -a "$output_file"
			echo "# Installing the CSI Theme..."  | tee -a "$output_file"
		
    	if restore_backup_to_root "$backup_dirct" "$backup_file_namect"; then
     	    echo "The CSI Theme restored successfully." | tee -a "$output_file"
	    echo "Setting permissions and configurations for the CSI Theme..." | tee -a "$output_file"
	    echo "$key" | sudo -S chown csi:csi -R /home/csi/ | tee -a "$output_file"			    
            echo "The CSI Theme installation and configuration completed successfully." | tee -a "$output_file"
	else
	    echo "Failed to restore the CSI Theme from the backup." | tee -a "$output_file"
	fi
	#else
	echo "Failed to download CSI Tools." | tee -a "$output_file"
	#return 1  # Download failed
		#fi
  
		#rm csi_linux_themes.txt &>/dev/null | tee -a "$output_file"
		
    #wget https://csilinux.com/downloads/csi_linux_themes.txt -O csi_linux_themes.txt | tee -a "$output_file"  	
    	dos2unix csi_linux_themes.txt  | tee -a "$output_file"		
    mapfile -t csi_linux_themes < <(grep -vE "^\s*#|^$" csi_linux_themes.txt | sed -e 's/#.*//')
		
    install_packages csi_linux_themes
  		# installed_packages_desc csi_linux_themes
		reset_DNS
		echo "# Configuring Background"	| tee -a "$output_file"
    update_xfce_wallpapers "/opt/csitools/wallpaper/CSI-Linux-Dark.jpg"  	
    	echo "Doing Grub stuff..."
        ### COMMAND NOT FOUND - another dependency        
    		echo $key | sudo -S "/sbin/modprobe zfs"
		
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
