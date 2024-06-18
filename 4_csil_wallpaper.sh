#!/bin/bash

echo "Add WALLPAPER to CSI Theme..." #| tee -a "$output_file"
#tar_file="csi_wallpaper.tar"
#echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="/usr/share/.logs/csil_wallpaper-$timestamp.log"
### | tee -a "$output_file"

sleep 5
echo "# Installing the CSI WALLPAPER Theme..." | tee -a "$output_file"

# Identify Desktop Environment (DE)
desktop_env=$(echo "${XDG_CURRENT_DESKTOP}")  #| tr '[[:upper:]]' '[[:lower:]]')
wallpaper_path="/opt/csitools/wallpaper/CSI-Linux-Dark-logo.jpg"

# Function to change wallpaper for GNOME
update_gnome_wallpaper() {
  echo "inside  GNOME file://$wallpaper_path"
  gsettings set org.gnome.desktop.background color-shading-type 'solid'
  gsettings set org.gnome.desktop.background primary-color '#000000'
  gsettings set org.gnome.desktop.background picture-options 'spanned'
  gsettings set org.gnome.desktop.background picture-opacity 100
  gsettings set org.gnome.desktop.background secondary-color '#000000'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.background picture-uri "file://${wallpaper_path}"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${wallpaper_path}"
}

# Function to change wallpaper for XFCE (using xfconf-query)
update_xfce_wallpapers() {
    local wallpaper_path="$1"  # Use the first argument as the wallpaper path
    if [[ -z "$wallpaper_path" ]]; then
        echo "Usage: update_xfce_wallpapers /path/to/your/wallpaper.jpg"
        return 1  # Exit the function if no wallpaper path is provided
    fi
    if [ ! -f "$wallpaper_path" ]; then
        echo "The specified wallpaper file does not exist: $wallpaper_path"
        return 1  # Exit the function if the wallpaper file doesn't exist
    fi
    xsetroot -solid black
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

# Check for GNOME
if [[ "$desktop_env" == "GNOME" ]]; then
  echo "Detected GNOME desktop"
  update_gnome_wallpaper  

# Check for XFCE
elif [[ "$desktop_env" == "XFCE" ]]; then
  echo "Detected XFCE desktop"
  update_xfce_wallpapers "$wallpaper_path"

else
  echo "Desktop environment not supported: $desktop_env"
fi

