#!/bin/bash

# Function to check internet connectivity
check_internet() {
    if ! ping -c 1 google.com &> /dev/null; then
        echo "Please connect to the internet and try again."
        exit 1
    fi
}

USERNAME=$(logname)

# Function to install the wallpaper changer
install() {
    # Create the necessary directories
    mkdir -p /home/$USERNAME/wallpaperchanger

    # Copy the Python script
    cp main.py /home/$USERNAME/wallpaperchanger/

    # Copy the requirements file
    cp requirements.txt /home/$USERNAME/wallpaperchanger/

    # Copy the Icon file
    cp awf.svg /home/$USERNAME/wallpaperchanger/

    # Prompt to install requirements
    read -s -N 1 -p "Do you want to install the required packages? [Y/n]: " install_requirements
    echo

    if [ "$install_requirements" = "n" ] || [ "$install_requirements" = "N" ]; then
        echo "Skipping installation of requirements."
    else
        # Install requirements
        pip3 install --no-cache-dir -r /home/$USERNAME/wallpaperchanger/requirements.txt
    fi

    # Set the ownership and permissions
    chown -R $USERNAME:$USERNAME /home/$USERNAME/wallpaperchanger
    chmod +x /home/$USERNAME/wallpaperchanger/main.py

    # Prompt to schedule the script with cron or create a desktop entry
    read -s -N 1 -p "Do you want to schedule the script? [Y/n]: " schedule_script
    echo

    if [ "$schedule_script" = "n" ] || [ "$schedule_script" = "N" ]; then
        # Create a desktop entry
        desktop_entry="/home/$USERNAME/.local/share/applications/wallpaper-changer.desktop"
        echo -e "[Desktop Entry]\nType=Application\nName=Wallpaper Changer\nExec=/usr/bin/python3 /home/$USERNAME/wallpaperchanger/main.py\nTerminal=false\nIcon=/home/$USERNAME/wallpaperchanger/awf.png" > "$desktop_entry"
        chmod +x "$desktop_entry"
        chown $USERNAME:$USERNAME "$desktop_entry"
        echo "Desktop entry created: $desktop_entry. Use it to run the script."
    else
        echo "Cron functionality is still a work in progress."
        echo "Creating a desktop entry instead."

        # read -p "Do you want to schedule the script with cron? (y/n): " schedule_with_cron
        # if [ "$schedule_with_cron" = "y" ] || [ "$schedule_with_cron" = "Y" ]; then
        #     if crontab -u $USERNAME -l >/dev/null 2>&1; then
        #         # Append the cron job if the crontab exists
        #         (crontab -u $USERNAME -l; echo "*/5 * * * * /usr/bin/python3 /home/$USERNAME/wallpaperchanger/main.py") | crontab -u $USERNAME -
        #     else
        #         # Create a new crontab with the cron job
        #         echo "export DISPLAY=:0 && */5 * * * * /usr/bin/python3 /home/$USERNAME/wallpaperchanger/main.py >> /home/$USERNAME/wallpaperchanger/logfile.log" | crontab -u $USERNAME -
        #     fi

        #     # Check if the cron job was added successfully
        #     if crontab -u $USERNAME -l | grep -q "/home/$USERNAME/wallpaperchanger/main.py"; then
        #         echo "Cron job added successfully."
        #     else
        #         echo "Failed to add cron job."
        #     fi

        # Create a desktop entry
        desktop_entry="/home/$USERNAME/.local/share/applications/wallpaper-changer.desktop"
        echo -e "[Desktop Entry]\nType=Application\nName=Wallpaper Changer\nExec=/usr/bin/python3 /home/$USERNAME/wallpaperchanger/main.py\nTerminal=false\nIcon=/home/$USERNAME/wallpaperchanger/awf.png" > "$desktop_entry"
        chmod +x "$desktop_entry"
        chown $USERNAME:$USERNAME "$desktop_entry"
        echo "Desktop entry created: $desktop_entry. Use it to run the script."
    fi

    echo "Installation completed."
}

# Function to uninstall the files and cron job
uninstall() {
    echo $USERNAME
    # Remove the installed files
    if [ -d "/home/$USERNAME/wallpaperchanger" ]; then
        rm -rf "/home/$USERNAME/wallpaperchanger"
        echo "Wallpaper changer folder removed."
    else
        echo "No wallpaper changer folder found."
    fi


    # Remove the cron job if present
    if crontab -l -u $USERNAME | grep -q "/home/$USERNAME/wallpaperchanger/main.py"; then
        crontab -l -u $USERNAME | grep -v "/home/$USERNAME/wallpaperchanger/main.py" | crontab -u $USERNAME -
        echo "Cron job removed."
    else
        echo "No cron job found."
    fi

    # Remove the desktop entry if present
    desktop_entry="/home/$USERNAME/.local/share/applications/wallpaper-changer.desktop"
    if [ -f "$desktop_entry" ]; then
        rm "$desktop_entry"
        echo "Desktop entry removed."
    else
        echo "No desktop entry found."
    fi

    echo "Uninstallation completed successfully."
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
        install
        ;;
    --uninstall)
        uninstall
        ;;
    *)
        echo "Invalid option. Usage: ./install.sh --install or ./install.sh --uninstall"
        exit 1
        ;;
esac
