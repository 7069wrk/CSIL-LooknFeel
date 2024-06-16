#!/bin/bash

# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="csil_slim-$timestamp.log"
### | tee -a "$output_file"

echo "Add LOGIN to CSI Theme..." | tee -a "$output_file"
#tar_file="csi_looknfeel.tar"
#echo $key | sudo -S tar --overwrite -xpf "$tar_file" -C /

# Check root privileges
if [[ $(id -u) != 0 ]] ; then
  echo "This script must be run with root privileges."
  exit 1
fi

# Update package list
#apt update

# Install SLIM
#echo $key | sudo -S apt install -y slim

# Backup slim config
#cp -v /etc/slim.conf /etc/slim.conf.org  # -v for verbose output

# Define custom configuration content (replace with your actual configuration)
CUSTOM_CONFIG=$(cat <<EOF
### CUSTOM CSIL SLIM.CONF
default_path /usr/local/bin:/usr/bin:/bin:/opt/csitools:/opt/csitools/helper:/home/csi/bin:/home/csi/.local/bin:/usr/sbin
default_xserver /usr/bin/X11/X
xserver_arguments -nolisten tcp
halt_cmd /sbin/shutdown -h now
reboot_cmd /sbin/shutdown -r now
console_cmd /usr/bin/xterm -C -fg white -bg black +sb -T "Console login" -e /bin/sh -c "/bin/cat /etc/issue.net; exec /bin/login"
xauth_path /usr/bin/X11/xauth
authfile /var/run/slim.auth
numlock on
login_cmd exec /bin/bash -login /etc/X11/Xsession %session
sessiondir /usr/share/xsessions/
screenshot_cmd scrot /root/slim.png
welcome_msg Welcome to CSI Linux
shutdown_msg The system is halting...
reboot_msg The system is rebooting...
default_user csi
focus_password yes
auto_login no   
current_theme csi2
lockfile /var/run/slim.lock
logfile /var/log/slim.log
EOF
)


# Check if custom config content is empty
if [[ -z "$CUSTOM_CONFIG" ]]; then
  echo "Custom configuration is empty. Please define content."
  exit 1
fi

# Check if backup file exists
if [[ -f /etc/slim.conf.org ]]; then
  # Backup already exists, overwrite slim.conf
  echo "Existing backup found, overwriting /etc/slim.conf"
  echo "$CUSTOM_CONFIG" > /etc/slim.conf
else
  # No backup found, create a backup before overwriting
  echo "Creating backup of /etc/slim.conf as /etc/slim.conf.org"
  cp -v /etc/slim.conf /etc/slim.conf.org
  echo "$CUSTOM_CONFIG" > /etc/slim.conf
fi

# Restart SLIM service (optional)
systemctl restart slim

echo "SLIM installed and new configuration file created."
