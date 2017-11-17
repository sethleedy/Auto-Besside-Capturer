#!/usr/bin/env bash

# Called by inotifywait

# Process wep.cap & wpa.cap files into upload.cap.
# Upload.Cap needs to be moved into upload directory and moved so it does not overwrite existing files with same name.

# After all this,
# 1] The script will execute all bash files in the caps/upload/ directory. These scripts are for uploading the new .cap files to website for processing or whatever.
# 1.1] After executing all the scripts, the .cap files will move to the archive directory for later manual upload, if needed.
# 2] OR I'll manually upload the upload.cap files into a cracking website from the archive directory.


# User:Group to chown the .cap files as. Don't want to keep them root.
chUser="seth"
chGroup="seth"


# Test for help
function display_help {
	echo "Help:"
	echo $0" optional arguments,"
	echo "You can use the argument '$0 -watch' to keep watch for more .cap files(program will not exit) to process automatically"
	echo ""

}

# Convert the .cap capture files into something more usable for uploading to websites.
function do_conversion() {

	$besside_file . upload/upload.new
	new_date=$(date); new_date=$(echo "${new_date}" | tr -s ':' '_')
	mv -b --backup=t upload/upload.new upload/"upload-$new_date.cap"

	# Remove the processed files. Compiled data is now in a single .cap file in the upload directory.
	rm_command=$(loc_file "rm")
	$rm_command -f *.cap
	$rm_command -f *.cap.~*

}

# Auto upload the converted .cap files to websites via purpose built scripts in the upload directory. Sites like http://wpa-sec.stanev.org
function do_upload() {


}


if [ "$1" != "" ]; then
	if [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" != "${1/:/}" ]; then
		display_help
		exit
	fi
fi

# use my custom functions
echo "Uni Funct Online ?: $unisystem_functions_online"
if [ "$unisystem_functions_online" == "false" ] || [ "$unisystem_functions_online" == "" ]; then
	uni_functions_paths=$(../find_up.sh . -name "uni_functions.sh")

	test_true="false"
	for test_paths in $uni_functions_paths # note that $uni_functions_paths must NOT be quoted here!
	do
		source "$test_paths" 2>/dev/null
		if [ "$?" -eq 0 ]; then
			test_true="true"
			break
		fi
	done
	if [ "$test_true" == "false" ]; then
		echo "Could not source the Uni System Functions (uni_functions.sh)"
		exit
	fi
fi

cd_current_script_dir

besside_file=$(loc_file "besside-ng-crawler")

if [ "$besside_file" != "" ]; then
	# Do existing .cap files first
	#if ls *.cap & > /dev/null; then
	if [[ -n $(shopt -s nullglob; echo *.cap) ]]; then # explain this line ??

		# Then convert
		do_conversion

		# After conversion, auto upload to website via the scripts within the upload directory
		do_upload

		# Make sure all these newly created files are not root owned.
		chown -R $chUser:$chGroup *

	fi

	if [ "$1" == "-watch" ]; then
		# Now watch for more
		inotifywait_file=$(loc_file "inotifywait")
		$inotifywait -m . --format '%:e %f' -e moved_to -e close_write |
			while read file; do
				#echo "OUTPUT: $read - $file"

				if substring "upload.cap" "$file" || substring "wep.cap" "$file" || substring "wpa.cap" "$file" ; then

					do_conversion

					# After conversion, auto upload to website via the scripts within the upload directory
					do_upload

					# Make sure all these newly created files are not root owned.
					chown -R $chUser:$chGroup *

					# Notify the user about this
					#play_wav "default_tone"
					#$speak "A capture is ready for uploading." &
				fi
			done
	fi
else
	echo "Cannot locate tool besside-ng-crawler. Install it to continue."
fi

exit 0
