#!/usr/bin/env bash

keyID="4eb90f30036d57050d3647c52cdf0c2f"
uploadURL="http://wpa-sec.stanev.org/?submit"

# Load echoColours for pretty output
source "../echoColours.sh"
#source "../../echoColours.sh"

function start_exec() {
	
	echo " "
	shw_info "Uploading to wpa-sec.staney.org with key ID of: $keyID"

	# Using curl command to post the .cap file and some key data.
	# First loop the .cap files and pass in the key ID.
	for fname in upload/*.cap; do # If no files are present, the loop will not be entered.
		curl --progress-bar --fail -H "Cookie: key=$keyID" --cookie "key=$keyID" --form "webfile=@${fname}" -o upload_result.html "$uploadURL"
		# From Chrome Network tab:
		#curl --progress-bar --fail -o upload_result.html -L --cookie "key=$keyID" --form "webfile=@${fname}" -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.9' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://wpa-sec.stanev.org/?my_nets' -H 'Cookie: key=4eb90f30036d57050d3647c52cdf0c2f' -H 'Connection: keep-alive' --compressed "$uploadURL"

		# If error, set flag variable.
		# Return this variable to caller script.
		# Caller script should then NOT delete the .cap files IF an error was flagged in this variable.
		if [ "$?" -ne 0 ]; then
			shw_warn "Error in uploading to $uploadURL."
			return 1
		fi
	done

	return 0
}
