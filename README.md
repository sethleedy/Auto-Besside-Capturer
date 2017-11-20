Auto Besside Capturer

Wardriving scenario setup.

This script will loop on besside-ng until you Ctrl-C it. It will then format the .cap file with besside-ng-crawler for upload. After that, it will loop the scripts within the "caps/upload" directory.

Within there is(at the moment) one script of mine to upload the .cap files for processing to wpa-sec.stanev.org. For the website upload portion, you will need to change the key to your own. It is set within "caps/upload/wpa-sec.stanev.org.sh" at the top of the file.

To start, use either "start_cracking.sh" or "start_with_screen.sh"

----
start_cracking.sh --help

    Help:

      ./start_cracking.sh <besside id> <WiFi Device> <Monitoring Device> 

      ./start_cracking.sh <besside id> to crack only or '', to crack all. BESSIDE must contain the colon separators. 

      ./start_cracking.sh <WiFi Device> to use for monitoring. 

      ./start_cracking.sh <Monitoring Device> in case it does not detect the device for monitoring correctly. 

      If the WiFi device is not specified, it defaults to wlan1. 

      If the monitoring device is not specified, it defaults to mon0. 

    Notes: 

      If stuck waiting for the WiFi device to appear, try the 'ESCape' button to shutdown the program.
