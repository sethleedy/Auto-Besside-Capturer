#!/usr/bin/env bash

# Load echoColours for pretty output
source "../../echoColours.sh"

function upload_cap() {

	# Insert code here to upload to a website.

	# Loop through the .sh files to execute them.
	# Now execute them in AlphNumeric order. Eg: install1.sh, install2.sh, install3.sh
		for fname in $(ls domain_scripts/ | sort -n); do # If no files are present, the loop will not be entered.
		
			# Load the functions within the files
			shw_grey "Sourcing script $fname"
			source "domain_scripts/$fname"
			
			# Execute the expected functions after sourcing.
				# Each time a new file is sourced, it should replace the previous function stored by the same name.
			type after_script_install_function &> /dev/null # Is the function live or present ?
			result=$?
			if [ $result -eq 0 ]; then # If so,
				shw_grey "Executing $fname"
				after_script_install_function # execute it.
			fi
			
		done
}