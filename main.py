from gi.repository import Gio
import urllib.request
from bs4 import BeautifulSoup
import os
import gi
import datetime
import subprocess
import time
import random
gi.require_version('Gio', '2.0')

###################### TRYING TO IMPLEMENT SCHEDULING########################
# subprocess.run(["xhost", "+SI:localuser:{}".format(os.getlogin())])
# os.environ['DISPLAY'] = ':0'

#############################################################################


def set_wallpaper(filepath):
    gsettings = Gio.Settings.new('org.gnome.desktop.background')
    gsettings.set_string('picture-uri', f'file://{filepath}')
    gsettings.apply()


def change_wallpaper(day):
    ajax_url = 'http://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=8'
    scriptdir = os.path.dirname(os.path.abspath(__file__))
    filepath = os.path.join(scriptdir, 'bing_image.jpg')

    # Try updating the wallpaper until successful
    while True:
        try:
            resp = urllib.request.urlopen(ajax_url)
            if resp.status == 200:
                xml_data = BeautifulSoup(resp, features='xml')
                urls = xml_data.findAll('url')
                url = urls[day].string
            download_link = f'https://bing.com{url}'
            urllib.request.urlretrieve(download_link, filepath)
            set_wallpaper(filepath)
            print('Wallpaper Set Successfully.')
            break  # Exit the loop if wallpaper is updated successfully
        except:
            print("Error updating wallpaper. Retrying...")
            time.sleep(5)  # Wait for 60 seconds before retrying


def write_current_date():
    scriptdir = os.path.dirname(os.path.abspath(__file__))
    filepath = os.path.join(scriptdir, 'last_run.txt')
    current_date = datetime.date.today().isoformat()

    with open(filepath, 'w') as file:
        file.write(current_date)


def read_last_run_date():
    scriptdir = os.path.dirname(os.path.abspath(__file__))
    filepath = os.path.join(scriptdir, 'last_run.txt')

    if not os.path.exists(filepath):
        return None

    with open(filepath, 'r') as file:
        last_run_date = file.read().strip()

    return last_run_date


# Check if the wallpaper needs to be updated based on the last run date
last_run_date = read_last_run_date()
current_date = datetime.date.today().isoformat()

if last_run_date is None or last_run_date != current_date:
    # Change the wallpaper
    try:
        change_wallpaper(0)
    except Exception as e:
        print(e)
else:
    # Cycle between wallpapers this week.
    try:
        change_wallpaper(random.choice([i for i in range(1, 8)]))
    except Exception as e:
        print(e)

# Write the current date to the file
write_current_date()
