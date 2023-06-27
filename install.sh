#!/bin/bash

animation() {
    echo " ___         ___         ___  "
    echo "|   | |\  | |   | |\  |   |   "
    echo "|-+-| | + | |-+-| | + |   +   "
    echo "|   | |  \| |   | |  \|   |   "

# sleep 2
}
echo_rainbow(){
    colors=("31" "32" "33" "34" "35" "36" "90" "91" "92" "93" "94" "95")
    for ((i = 0; i <= 12; i++)); do
        color_index=$((i % ${#colors[@]}))
        echo -e "\e[${colors[color_index]}m" #\e[0m
        animation
        sleep 0.25
        clear
    echo -e "\e[0m"
    done
}

progress() {
    local duration=$1
    local bar_length=20
    local sleep_duration=$(bc <<< "scale=2; $duration / $bar_length")

    echo -n "["
    for ((i=0; i<bar_length; i++)); do
        echo -n "="
        sleep $sleep_duration
    done
    echo "]"
}

progress_bar() {
    local pid=$1
    local spin='-\|/'

    echo -n "WORKING..."

    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\b${spin:i:1}"
            sleep 0.1
        done
    done

    echo -ne "\b"
}

USERNAME=$(logname)

# Function to install the wallpaper changer
install() {
    (
    echo ""
    # Copy the Folder
    cp -r bin/ /home/$USERNAME/.local/share/wallpaperchanger

    sleep 2
    echo "Files Copied."

    sleep 1
    # Set the ownership and permissions
    echo "setting file ownership"
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.local/share/wallpaperchanger
    chmod +x /home/$USERNAME/.local/share/wallpaperchanger/main.py
    echo "done")&

    progress_bar $!
    wait
    progress 1

    # Prompt to install requirements
    read -s -N 1 -p "Do you want to install the required packages? [y/n]: " install_requirements
    echo ""

    (   if [ "$install_requirements" = "n" ] || [ "$install_requirements" = "N" ]; then
        echo "Skipping installation of requirements."
        sleep 1
    else
        # Install requirements
        echo "Installing requirements"
        pip3 install --no-cache-dir -r /home/$USERNAME/.local/share/wallpaperchanger/requirements.txt
        sleep 1
    fi

    # Create a desktop entry
    echo ""
    echo "Creating Desktop entry"
    desktop_entry="/home/$USERNAME/.local/share/applications/bing-wallpaper.desktop"
    sleep 1
    echo -e "[Desktop Entry]\nType=Application\nCategories=Utility\nComment=New Wallpaper Everyday\nName=Bing Wallpaper\nExec=/usr/bin/python3 /home/$USERNAME/.local/share/wallpaperchanger/main.py\nTerminal=false\nIcon=/home/$USERNAME/.local/share/wallpaperchanger/awf.svg" > "$desktop_entry"
    chmod +x "$desktop_entry"
    chown $USERNAME:$USERNAME "$desktop_entry"
    sleep 1
    echo "Desktop entry created: $desktop_entry. Use it to run the script.")&
    progress_bar $!
    wait
    progress 1

    # Prompt to schedule the script or create a desktop entry
    read -s -N 1 -p "Do you want to schedule the script? [y/n]: " schedule_script
    echo ""
    (if [ "$schedule_script" = "n" ] || [ "$schedule_script" = "N" ]; then
        echo ""
    else
        echo ""
        # Create a desktop entry
        desktop_entry="/home/$USERNAME/.config/autostart/bing-wallpaper.desktop"
        echo -e "[Desktop Entry]\nType=Application\nCategories=Utility\nComment=New Wallpaper Everyday\nName=Bing Wallpaper\nExec=/usr/bin/python3 /home/$USERNAME/.local/share/wallpaperchanger/main.py\nTerminal=false\nIcon=/home/$USERNAME/.local/share/wallpaperchanger/awf.svg" > "$desktop_entry"
        chmod +x "$desktop_entry"
        chown $USERNAME:$USERNAME "$desktop_entry"
        sleep 1
        echo -e "\e[32mWallpaper Changer scheduled, Enjoy Fresh Wallpapers.\e[0m"
        sleep 2
    fi)&
    progress_bar $!
    wait
    progress 1
    clear
    echo -e "\e[36mUse the wallpaper changer icon to change wallpaper anytime. Find the icon in applications menu.\e[0m"
    echo -e "\e[33mIf you want notifications install libnotify module, run 'sudo apt install libnotify-bin' for debian based OS.\e[0m"
    read -n 1 -p "Press any key to exit!" key
    clear
}

# Function to uninstall the files and cron job
uninstall() {
    (echo ""
    echo -e "\e[31mPerforming uninstallation"
    # Remove the installed files
    if [ -d "/home/$USERNAME/.local/share/wallpaperchanger" ]; then
        rm -rf "/home/$USERNAME/.local/share/wallpaperchanger"
        echo "Wallpaper changer Uninstalled."
        sleep 1
    else
        echo "No Wallpaper changer installation found."
        sleep 1
    fi
    # Remove the desktop entry if present
    desktop_entry="/home/$USERNAME/.local/share/applications/bing-wallpaper.desktop"
    if [ -f "$desktop_entry" ]; then
        rm "$desktop_entry"
        echo "Desktop entry removed."
        sleep 1
    else
        echo "No desktop entry found."
        sleep 1
    fi
    # Remove the scheduler entry if present
    desktop_entry="/home/$USERNAME/.config/autostart/bing-wallpaper.desktop"
    if [ -f "$desktop_entry" ]; then
        rm "$desktop_entry"
        echo "Scheduler entry removed."
        sleep 1
    else
        echo "No scheduler entry found."
        sleep 1
    fi

    echo -e "\e[32mUninstallation completed successfully.\e[0m")&
    progress_bar $!
    progress 3
    wait
    clear
}

# Main script

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31mPlease run the script with root privileges.\e[0m"
    exit 1
fi

# Check the command-line argument
case $1 in
    --install)
        echo_rainbow
        install
        ;;
    --uninstall)
        echo_rainbow
        uninstall
        ;;
    *)
        echo -e "\e[31mInvalid option. Usage: ./install.sh --install or ./install.sh --uninstall\e[0m"
        exit 1
        ;;
esac

# echo "AUTHOR: ANANT"
