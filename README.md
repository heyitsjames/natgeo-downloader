#NatGeo Downloader#

* Downloads the National Geographic Picture of the Day and sets it to your Desktop  

#### Dependencies ####
* If you want to run just the python script, install beautifulsoup:  
`pip install beautifulsoup4`

* You'll also need AppKit, which can be installed via PyObjC:  
`pip install pyobjc`  
Or just by itself:  
`pip install AppKit`  
* If you'd like to package this into a Mac App, you'll need py2app:  
`pip install py2app`


As a note, AppKit has `PyGObject` as a dependency, and often fails on a pip install. I know of no workaround for this other than to install from source as of right now. If this strikes you as irritating, bug the PyGObject guys to fix their build for pip.


#Usage#
To use the mac app, just place it in your Applications directory and click on it. As for the python script, you can run it as a background process by typing
`python downloader.py &` Into your terminal. Or run it in a screen.
