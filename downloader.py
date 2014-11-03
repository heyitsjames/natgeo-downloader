#!/usr/bin/python

import urllib2, sys, os, getpass, imp


soup_module = imp.find_module('bs4')

if(soup_module[1]):
    bs4 = imp.load_module('bs4', None, soup_module[1], soup_module[2])
else:
    raise ImportError('Could not import module BeautifulSoup4')

from bs4 import BeautifulSoup as bs4

'''
This script grabs the daily National Geographic image of the day, 
and sets it as your desktop background every day.
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
        try:
            link = soup.find('div', class_='primary_photo').find('img').attrs['src']
        except AttributeError:
            # couldn't find the right div, 
            # try again next interval (not a robust solution)
            print "there was an error parsing the html"
            return None, None


    # now, prepend http onto the url
    link = 'http:{0}'.format(link)
    title = soup.find('div', id='page_head').find('h1').contents[0].encode('ascii', 'ignore')
    return link, title

def download_and_name_image(link, title):
    try: 
        image = urllib2.urlopen(link)
    except Exception as e:
        # network error. Return None
        return None
    path_to_pictures = '/Users/' + getpass.getuser() + '/Pictures/'

    # sets the image name and file extension
    desktop_picture_path = '{0}NatGeo-{1}.{2}'.format(
                            path_to_pictures, title, link.split('.')[-1])

    # writes the file and returns the path
    output = open(desktop_picture_path, 'w')
    output.write(image.read())
    output.close()

    return desktop_picture_path

def main():
    link, title = get_image_link_and_title()
    if link and title:
        desktop_picture_path = download_and_name_image(link, title)
        if desktop_picture_path:
            sys.stdout.write(desktop_picture_path)

if __name__ == "__main__":
    main()
