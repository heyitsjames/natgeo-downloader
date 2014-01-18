#!/usr/bin/python

import urllib2
import sys
import os
import getpass
import time
import subprocess
import sqlite3
from datetime import datetime, date, timedelta
from datetime import date
from bs4 import BeautifulSoup as bs4
from AppKit import NSWorkspace, NSScreen
from Foundation import NSURL


'''
This simple script grabs the daily National Geographic
image of the day, and sets it as your desktop background
'''
def get_image_link_and_title():
    try:
        page = urllib2.urlopen(
            "http://photography.nationalgeographic.com/photography/photo-of-the-day/")
    except urllib2.URLError:
        # Looks like it didn't work, just return from the function 
        # and try again at the next interval
        print "there was an error opening the url"
        return None, None
    soup = bs4(page)
    try:
        link = soup.find('div', class_='download_link').find('a').attrs['href']
    except AttributeError:
        #looks like there wasn't a download link. 
        # just grab the low-res image instead
        link = soup.find('div', class_='primary_photo').find('img').attrs['src']

    # now, prepend http onto the url
    link = 'http:{0}'.format(link)
    title = soup.find('div', id='page_head').find('h1').contents[0]
    return link, title

def download_and_name_image(link, title):
    try: 
        image = urllib2.urlopen(link)
    except Exception as e:
        # network error. Return None
        return None
    path_to_pictures = '/Users/' + getpass.getuser() + '/Pictures/'

    # sets the image name and file extension
    desktop_picture_path = '{0}NatGeo - {1}.{2}'.format(
                            path_to_pictures, title, link.split('.')[-1])

    # writes the file and returns the path
    output = open(desktop_picture_path, 'w')
    output.write(image.read())
    output.close()

    return desktop_picture_path

def set_desktop_background(desktop_picture_path):
    file_url = NSURL.fileURLWithPath_(desktop_picture_path)
    ws = NSWorkspace.sharedWorkspace()

    screens = NSScreen.screens()
    for screen in screens:
        ws.setDesktopImageURL_forScreen_options_error_(file_url, screen, {}, None)

def should_download_new_image(next_check_time):
    return datetime.now() >= next_check_time

def two_am_tomorrow():
    return (datetime.combine(date.today() + 
            timedelta(1), datetime.min.time()) + 
            timedelta(hours=2))

def main():
    old_image = ''
    next_check_time = datetime.now()
    while True:
        if should_download_new_image(next_check_time):
            link, title = get_image_link_and_title()
            if link and title:
                desktop_picture_path = download_and_name_image(link, title)
                if desktop_picture_path:
                    set_desktop_background(desktop_picture_path)
                    # set the next check time to 2am the next day.
                    next_check_time = two_am_tomorrow() 
        time.sleep(30)


if __name__ == "__main__":
    main()
