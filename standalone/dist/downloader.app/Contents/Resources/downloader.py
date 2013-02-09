#!/usr/bin/python

import urllib2, sys, os, getpass, time
from bs4 import BeautifulSoup as bs4
from datetime import datetime

''' 
This simple script grabs the daily National Geographic 
image of the day, and sets it as your desktop background
'''
#global variable of the current image name. if it's the same, then don't regrab.
current_image = ''

def grab_image():
    global current_image
    page = urllib2.urlopen("http://photography.nationalgeographic.com/photography/photo-of-the-day/")
    soup = bs4(page)
    try:
        link = soup.find('div', class_='download_link').find('a').attrs['href']
    except AttributeError:
        #looks like there wasn't a download link. just grab the low-res image instead
        link = soup.find('div', class_='primary_photo').find('img').attrs['src']
    title = soup.title.contents[0]
    title_clean = ''.join(e for e in title if e.isalnum())
    image = urllib2.urlopen(link)
    name = title_clean + '.' + link.split('.')[-1]
    #name = "National_Geographic_Picture_Of_The_Day" + '.' + link.split('.')[-1]

    #check against current image. if same, return. else, delete old image and continue
    if name != current_image:
        path_to_pictures = '/Users/' + getpass.getuser() + '/Pictures/'
        old_image_path = path_to_pictures + current_image
        image_path =  path_to_pictures + name
        if current_image != '':
            os.remove(old_image_path)
        current_image = name
        output = open(image_path, 'w')
        output.write(image.read())
        output.close()
        os.system('defaults write com.apple.desktop Background \'{default = {ImageFilePath = "' + image_path + '"; };}\'')
        os.system('killall Dock')

def check_time():
    now = datetime.utcnow()
    replace_time = now.replace(hour=10, minute=0, second=0, microsecond=0)
    if now >= replace_time:
        grab_image()

def main():
    while True:
        check_time()
        time.sleep(15)
   
if __name__ == "__main__":
    main()