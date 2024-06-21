#!/bin/bash

### Add the CSI Linux tag to top right of terminal
# GET SUDO
echo "Please enter your sudo password:"
read -s key

# LOG FOR NEW CSIL SYSTEM
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output_file="$HOME/csil_terminal-$timestamp.log"
touch "$output_file"
echo $key | sudo -S chmod 7777 "$output_file"### | tee -a "$output_file"

# install FIGLET
echo "installing FIGLET" | tee -a "$output_file"
echo $key | sudo -S apt install figlet

# get FIGLET fonts
echo $key | sudo -S git clone https://github.com/xero/figlet-fonts /usr/share/figlet/fonts

# edit .bashrc
#exit sudo
sudo -k

#echo "figlet -f /usr/share/figlet/fonts/Digital -r \"CSI Linux\"" >> ~/.bashrc
sed -i '$ a figlet -f /usr/share/figlet/fonts/Digital -r "CSI Linux"' ~/.bashrc

# set TERMINAL theme
# Text color (change '33' for different colors)
#text_color="\033[33m"  

# Background color (change '44' for different colors)
#background_color="\033[44m"  

# Reset color at the end
#reset_color="\033[0m"

#clear  # Optional: Clear the screen

# Set your preferred prompt style
#PS1="$text_color\u@\h: \w > $reset_color" 

# Apply colors and prompt
#echo -e "$background_color$text_color Welcome to your Custom Terminal! $reset_color"

# Your other commands here...

