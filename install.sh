#!/bin/bash

animation() {
    echo " ___         ___         ___  "
    echo "|   | |\  | |   | |\  |   |   "
    echo "|-+-| | + | |-+-| | + |   +   "
    echo "|   | |  \| |   | |  \|   |   "

sleep 2
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
    echo "JOB completed."
}

USERNAME=$(logname)

# Function to install the wallpaper changer
install() {
    # Create the necessary directories
    (
    # Copy the Folder
    cp -r bin/ /home/$USERNAME/.local/share/wallpaperchanger

    sleep 2
    echo "Files Copied."

    sleep 1
    # Set the ownership and permissions
    echo "setting file ownsership"
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.local/share/wallpaperchanger
    chmod +x /home/$USERNAME/.local/share/wallpaperchanger/main.py
    echo "done")&

    progress_bar $!
    wait
    progress 1

    # Prompt to install requirements
    read -s -N 1 -p "Do you want to install the required packages? [y/n]: " install_requirements
    echo ""

    (if [ "$install_requirements" = "n" ] || [ "$install_requirements" = "N" ]; then
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
        echo "Wallpaper Changer scheduled, Enjoy Fresh Wallpapers"
        sleep 2
    fi)&
    progress_bar $!
    wait
    progress 1
}

# Function to uninstall the files and cron job
uninstall() {
    (echo ""
    echo "performing uninstallation"
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

    echo "Uninstallation completed successfully.")&
    progress_bar $!
    wait
    progress 1
}

# Main script

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run the script with root privileges."
    exit 1
fi

# Check the command-line argument
case $1 in
    --install)
        animation
        install
        ;;
    --uninstall)
        animation
        uninstall
        ;;
    *)
        echo "Invalid option. Usage: ./install.sh --install or ./install.sh --uninstall"
        exit 1
        ;;
esac

echo "AUTHOR: ANANT"