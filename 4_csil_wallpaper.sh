#!/bin/bash

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

echo "Add VORTEX to CSI Theme..." #| tee -a "$output_file"
#tar_file="csi_wallpaper.tar"
#echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

sleep 5
echo "# Installing the CSI WALLPAPER Theme..." #| tee -a "$output_file"
xsetroot -solid black
update_xfce_wallpapers "/opt/csitools/wallpaper/CSI-Linux-Dark.jpg"


### single desktop wallpaper
#gsettings set org.gnome.desktop.background picture-uri file://///opt/csitools/wallpaper/CSI-Linux-Dark.jpg  
#gsettings set org.gnome.desktop.background picture-uri file://///opt/csitools/wallpaper/CSI-Linux-Dark-logo.jpg  
