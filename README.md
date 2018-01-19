Auto Besside Capturer

Wardriving scenario setup.

This script will loop on besside-ng until you Ctrl-C it. It will then format the .cap file with besside-ng-crawler for upload. After that, it will loop the scripts within the "caps/upload" directory.

Within there is(at the moment) one script of mine to upload the .cap files for processing to wpa-sec.stanev.org. For the website upload portion, you will need to change the key to your own. It is set within "caps/upload/wpa-sec.stanev.org.sh" at the top of the file.

To start, use either "start_cracking.sh" or "start_with_screen.sh"

----

Help:

	./start_cracking.sh <besside id> <WiFi Device> <Monitoring Device> 
	<besside id> to crack only or '', to crack all. BESSIDE must contain the colon separators. 
	<WiFi Device> to use for monitoring. 
	<Monitoring Device> in case it does not detect the device for monitoring correctly. 

	If the WiFi device is not specified, it defaults to the first auto detected WiFi device that contains Monitor mode. 
	If the Monitoring device is not specified, it defaults to a detected created device, normally mon0. 

	Notes: 
	If stuck waiting for the WiFi device to appear, try the 'ESCape' button to shutdown the program. 

	The wpa-sec.stanev.org module needs a key specified. Goto that website and sign up for it. 
	Place a copy of the key in a file with the name formatted as "<websiteName>.key" Eg: "wpa-sec.stanev.org.key", or in the top of the module file located in caps/upload/. 


