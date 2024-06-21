#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

echo "Add WALLPAPER to CSI Theme..." #| tee -a "$output_file"
#tar_file="csi_wallpaper.tar"
#echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="$HOME/csil_wallpaper-$timestamp.log"
touch "$output_file"
echo $key | sudo -S chmod 7777 "$output_file"
### | sudo -S tee -a "$output_file"

sleep 5
echo "# Installing the CSI WALLPAPER Theme..." | sudo -S tee -a "$output_file"

# Identify Desktop Environment (DE)
desktop_env=$(echo "${XDG_CURRENT_DESKTOP}" | tr '[[:upper:]]' '[[:lower:]]')
wallpaper_path="/opt/csitools/wallpaper/CSI-Linux-Dark-logo.jpg"

# Function to change wallpaper for GNOME
update_gnome_wallpaper() {
  #echo "inside  GNOME file://$wallpaper_path"
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
        echo "The specified wallpaper file does not exist: $wallpaper_path" | sudo -S tee -a "$output_file"
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
                echo "Updating wallpaper for ${property_path} to ${wallpaper_path}" | 
                xfconf-query -c xfce4-desktop -p "${property_path}" -n -t string -s "${wallpaper_path}"
            done
        done
    done
}

# Check for GNOME
if [[ "$desktop_env" == "ubuntu:gnome" || "$desktop_env" == "GNOME" || "$desktop_env" == "ubuntu:GNOME" ]]; then
  echo "Detected GNOME desktop" | sudo -S tee -a "$output_file"
  update_gnome_wallpaper  

# Check for XFCE
#elif [[ "$desktop_env" == "XFCE" || "$desktop_env" == "xfce" ]]; then
#  echo "Detected XFCE desktop" | sudo -S tee -a "$output_file"
#  update_xfce_wallpapers "$wallpaper_path"

else 
  update_xfce_wallpapers "$wallpaper_path"
  echo "Presuming XFCE"
fi

sleep 5
echo "xfce4-session" | tee ~/.xsession

sleep 5

# Define custom configuration content (replace with your actual configuration)
CUSTOM_CONFIG=$(cat <<EOF
[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/opt/csitools/wallpaper/CSI-Linux-Dark-logo.jpg'
[User]
Session=
XSession=xfce
Background=/opt/csitools/wallpaper/CSI-Linux-Dark.jpg
Icon=/var/lib/AccountsService/icons/csi
SystemAccount=false
[InputSource0]
xkb=us
EOF
)


# Check if custom config content is empty
if [[ -z "$CUSTOM_CONFIG" ]]; then
  echo "Custom configuration is empty. Please define content."
  exit 1
fi

# Check if backup file exists
if [[ -f /var/lib/AccountsService/users/csi ]]; then
  # Backup already exists, overwrite slim.conf
  echo "Existing backup found, overwriting /etc/slim.conf"
  echo "$CUSTOM_CONFIG" > /var/lib/AccountsService/users/csi
else
  # No backup found, create a backup before overwriting
  echo "Creating backup of /etc/slim.conf as /etc/slim.conf.org"
  echo $key | sudo -S mv -v /var/lib/AccountsService/users/csi /var/lib/AccountsService/users/csi.org
  echo "$CUSTOM_CONFIG" > /var/lib/AccountsService/users/csi
fi

