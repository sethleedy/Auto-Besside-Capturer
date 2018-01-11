#!/usr/bin/env bash

# Deposit the "find_up.sh" script in the directory or in a system path.
# Use this snippet of code to access the Uni_Functions.sh,
	## use my custom functions
	#uni_functions_path=$(./find_up.sh . -name "uni_functions.sh")

	#test_true=false

	#source "$uni_functions_path" 2>/dev/null
	#if [ "$?" -eq 0 ]; then
		#test_true=true
	#fi

	#if [ "$test_true" = false ]; then
		#echo "Could not source the Uni System Functions (uni_functions.sh)"
		#exit
	#fi

# Check if passed function name exists.
	#FN="sfn_exists"
	#if ! fn_exists $FN; then
			#echo "Hey, $FN does not exist ! Duh."
	#fi
function fn_exists() {
	# appended double quote is an ugly trick to make sure we do get a string -- if $1 is not a known command, type does not output anything
	[ `type -t $1`"" == 'function' ]
}

# checks to see if the needle exists in the cache_arr
# @param $1 mixed  Needle
# @return  Success (0) if value exists, Failure (1) otherwise
function in_array() {
	needle="$1"

	for hay in "${!cache_arr[@]}"; do
		#echo "Hay: $hay , Needle: $needle"
		if [ "$hay" == "$needle" ]; then
			in_array_key="$hay"
			in_array_val="${cache_arr[$hay]}"
			#echo "returning 0"
			return 0
		fi
	done
	#echo "returning 1"
	return 1
}

# Loads cache from disk if it has not been loaded yet. Runs once per program start.
# Add_to_cache_loc_file will keep it up to date on disk.
function load_loc_cache_from_disk() {

	cache_loaded_from_disk="false"
	#echo "Checking Cache"

	# if the file exists and is not empty.
	if [ -f .loc_cache.txt ] && [ -s .loc_cache.txt ]; then
		declare -Ag cache_arr
		source ".loc_cache.txt"

		# Check contents with a builtin lookup of the key "uni_sqlite_db_functions.sh". It should be blank.
		if [ "${cache_arr[uni_sqlite_db_functions.sh]}" == "" ]; then
			echo "Error finding an item in the loc cache. Cache may have not loaded correctly."
		#else
			#echo "Cache Loaded"
		fi

		cache_loaded_from_disk="true"
	fi

}
function add_to_cache_loc_file() {
	# Add the $1 filename key with the value of $2 to loc_file cache
	# $3 is optional expiration time, expressed in seconds, for the new entry. Default is 3900(65 mins).

	# we are saving a cache copy on disk so if the Uni System reloads, we reload the cache from a file.
	if [ "$cache_loaded_from_disk" == "false" ]; then
		load_loc_cache_from_disk
	fi

	#Unix=( ["lhunath"]="Maarten Billemont" ["lhunath2"]="Maarten Billemont2" );
	#Unix=( "${Unix[@]}" ["lhunath3"]="Maarten Billemont3" )
	if [ "$1" != "" ]; then
		declare -i curr_expire_date=$(date +%s)
		expire_key=$file_name"_expire"
		declare -i check_expire=${cache_arr[$expire_key]}
		if [ "$curr_expire_date" -gt "$check_expire" ]; then # Time expired, updated it.
			# Add it to the array
			cache_arr[$1]="$2"

			if [ "$3" != "" ]; then
				declare -i expire_date=$(date +%s)+$3
			else
				if [ "$2" == "" ]; then # In the case of a file not being found, we record it as blank. Because, it take a long time to search for it each time the script runs. This will research for it after the timeout of 30 mins.
					declare -i expire_date=$(date +%s)+1800 # 1800 secs = 30 mins
				else
					declare -i expire_date=$(date +%s)+3900 # 3900 secs = 65 mins
				fi
			fi
			expire_key_name="$1"
			expire_key=$expire_key_name"_expire"

			# Add it to the array
			cache_arr[$expire_key]="$expire_date"
		fi

		# Dump the current array to file
		declare -p cache_arr > .loc_cache.txt

	#else
		#echo "Please add_to_cache_loc_file() with two arguments"
	fi
	#echo "End print Array Item: $file_name -> "${cache_arr["$file_name"]}

}

# Simply see if the cache holds a filename
function check_loc_file_cache() {
	# $1 = filename
	filename="$1"

	# Dim array to hold name of variable and the path value for it.
	# Look up the variable name. If it does not exist in the array OR it does exist and it is past the expire cache time, search.

	#echo "Start print Entire Array: "
	#echo "Look for: $file_name"
	#echo "=="${cache_arr[@]}
	#echo "#="${#cache_arr[@]}

	# Search array for the filename and pull it into the path. Else, do a search.
	# If the cache_arr says the entry has expired, do a search. function add_to_cache_loc_file will update whatever is found, as it is what is called right after the function loc_file.
	in_array "$filename"

	if [ $? -eq 0 ]; then
		echo "true"
		return 0
	else
		echo "false"
		return 1
	fi
}

# Find the location of a script and return the path + script
# Returns the first one found.
# Use like; rm_command=$(loc_file "rm")
# Will return the path and command to the variable "rm_command" and allow you to use it via $rm_command "File_to_delete"
# Optional Second Argument ( $2 ):
#	1] is to be search paths, separated by spaces. Eg; rm_command=$(loc_file "rm" "/bin /sbin /usr/bin /usr/sbin")
#	2] or the word "required" if you want the script to exit if the file is not found.
function loc_file() {

	file_name="$1"
	file_name_search_path="$2"

	# Dim array to hold name of variable and the path value for it.
	# Look up the variable name. If it does not exist in the array OR it does exist and it is past the expire cache time, search.

	#echo "Start print Entire Array: "
	#echo "Look for: $file_name"
	#echo "=="${cache_arr[@]}
	#echo "#="${#cache_arr[@]}

	# Search array for the filename and pull it into the path. Else, do a search.
	# If the cache_arr says the entry has expired, do a search. function add_to_cache_loc_file will updated whatever is found as it is what is called right after the function loc_file.
	declare -i curr_expire_date;curr_expire_date=$(date +%s)
	expire_key=$file_name"_expire"
	declare -i check_expire;check_expire=${cache_arr[$expire_key]}
	in_array "$file_name"
	if [ $? -eq 0 ]; then
		if [ "$curr_expire_date" -lt "$check_expire" ]; then
			loc_file_return=${cache_arr[$file_name]}

			# Return the path+file
			echo "$loc_file_return"

			#echo "Key: $file_name -> Path: $loc_file_return" >> .incache
			#echo "Key Expire: $check_expire" >> .incache
			return
		fi
	fi

	loc_file_return=$(type "$file_name" 2>/dev/null)
	#echo " "
	#echo "=0 $loc_file_return within $pathing"
	#echo " "
	if [ $? -eq 1 ] || [ "$loc_file_return" == "" ]; then

		# Before actually searching, consult the cache.
		# By caching, we speed up the apps greatly, even on SSDs. The script will have to search at least once though.
		# A timeout on the cache can be more precise. As of right now, 3 hours.
		# Code later; per file cache. Allow the loc_file function to accept a argument for a cache time out to be placed into the cache entry. Useful for files that change locations often.


		# Pass as second arg a space separated list of paths to search within for $file_name arg.
		# I was doing just /, but it can be too slow...
		# Recommend as the default, all command paths. ". /home/seth/unisystem /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /etc/init.d ~ /"
		if [ "$file_name_search_path" == "" ]; then
			# Good default. Same directory as called from and all of the system. But SLOW!
			sec_arg=". /home/seth/unisystem /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /etc/init.d /"
			#sec_arg="/home/seth/unisystem ."
		else
			sec_arg="$file_name_search_path"
		fi

		for pathing in $sec_arg # note that $sec_arg must NOT be quoted here!
		do
				# Option: -ignore_readdir_race
				# If a file disappears after its name has been read from a directory but before find gets around to examining the file with stat, don't issue an error message. If you don't specify this option, an error message will be issued. This option can be useful in system scripts (cron scripts, for example) that examine areas of the filesystem that change frequently (mail queues, temporary directories, and so forth), because this scenario is common for those sorts of directories.
			#echo "PATHING: $pathing"

			loc_file_return=$(find $pathing -ignore_readdir_race \( -type f -lname "$file_name" -not -ilname ".*" -not -path "*/.*/*" \)  2>/dev/null | head -1)
			if [ "$loc_file_return" == "" ]; then
				loc_file_return=$(find $pathing -ignore_readdir_race \( -type f -name "$file_name" -not -iname ".*" -not -path "*/.*/*" \)  2>/dev/null | head -1)
			fi
			#echo " "
			#echo "=1 $loc_file_return within $pathing"
			#echo " "

			if [ "$loc_file_return" != "" ]; then
				#echo " "
				#echo "Breaking. Found: $loc_file_return"
				#echo " "
				break
			fi
		done

	else
		# The following is what works in terminal, strange in script. In script the return does not have the (). So a different cut is required.
		#loc_file_return=$(type "$file_name" | cut -d " " -f 4 | cut -d "(" -f 2 | cut -d ")" -f 1)

		# The following works in script, but not terminal...(strange, different results).
		loc_file_return=$(type "$file_name" | cut -d " " -f 3)

		#echo "=2 $loc_file_return"
	fi

	# Return the path+file if it exists.
	# If the items were required, exit the script with the explanation message.
	if [ "$loc_file_return" == "" ] && [ "$2" == "required" ]; then
		echo "Could not locate the required file: $file_name."
		echo "Exiting!"
		exit 1
	else
		echo "$loc_file_return"
	fi
}


# String matching
# Returns if found or not.
# Call function, string to find and then, pass string to search.
# Use like; str_check=$(substring "wep.cap" "$file_name")
function substring() {
    reqsubstr="$1"
    shift
    string="$@"
    if [ -z "${string##*$reqsubstr*}" ]; then
        #echo "String '$string' contain substring: '$reqsubstr'.";
        return 0
    else
        #echo "String '$string' don't contain substring: '$reqsubstr'."
        return 1
    fi

    return 1
}

# Play a wav file
# Arg 1 = wave file or if file does not exist, a preset file.
# Arg 2 = how many times. 1 is default if not specified. A * means don't stop. (To stop it later, use function stop_wav() )
function play_wav() {

	# Customize here until setup script is done. Set to use aplay right now.
	# Find the aplay or other program using the loc_file()
	play_wav_command=$(loc_file "aplay" "/usr/bin")
	add_to_cache_loc_file "aplay" "$play_wav_command" # Add it the cache.
	play_wav_command_args="-q"

	# Find the wav file
	sound_byte=$(loc_file "$1" "/home/seth/unisystem/scripts/system/speechtools/sound_effects")
	add_to_cache_loc_file "$1" "$sound_byte" # Add it the cache.

	# If we cannot find the wav file, use a preset by that name.
	if [ "$sound_byte" == "" ]; then
		#Match a preset
		case "$1" in
			default_tone)
				sound_byte=$(loc_file "a_very_nice_single_tone.wav" "/home/seth/unisystem/scripts/system/speechtools/sound_effects")
				add_to_cache_loc_file "a_very_nice_single_tone.wav" "$sound_byte" # Add it the cache.
				;;

			general_error)
				sound_byte=$(loc_file "criticalstop.wav" "/home/seth/unisystem/scripts/system/speechtools/sound_effects")
				add_to_cache_loc_file "criticalstop.wav" "$sound_byte" # Add it the cache.
				;;

			*)
				#If no preset matches, exit with error code 1
				return 1
 		esac



	fi

	# Play wav $2 amount of times. If $2 == *, then play in the background until killed by function stop_wav()
	if [ "$2" == "*" ]; then
		stop_count=9000
	elif [ "$2" == "" ]; then
		stop_count=1
	else
		stop_count=$2
	fi
	loop_count=0
	#echo "Play Command: $play_wav_command"
	#echo "Sound: $sound_byte"
	while [ $loop_count -ne $stop_count ]; do
		$play_wav_command $play_wav_command_args $sound_byte
		loop_count=$((loop_count+1))
	done

}

#SOO, it makes no since to call this function until you have already run your script from the correct directory. Because the "source ../scripts/??" path only works if you start it from the directory of the script referencing this function.
# Change to current script directory
function cd_current_script_dir() {

	# Remember the old directory, so we can switch back if need be.
	old_dir_before_cd_current_dir=$(pwd)

	# This fancy thing changes to the directory of the script if it is run from another location
	cd ${0%/*}

}

# Utility to log all echos AND display to screen
# $1 is the item to echo and/or log.
# $2 is the log file- Required.
function log_and_echo {

	arr_or_str="$1"
	write_log_file="$2"

	#if [ declare -p "$arr_or_str" 2>/dev/null | grep -q 'declare \-a' ]; then
	if [ declare -p "$arr_or_str" 2>/dev/null ]; then
		if [ ! be_quiet ]; then
			echo "array"
		fi
		echo "${arr_or_str[@]}" >> $write_log_file
		if [ ! be_quiet ]; then
			echo "${arr_or_str[@]}"
		fi
	else
		echo "$arr_or_str" >> $write_log_file
		if [ ! be_quiet ]; then
			echo "$arr_or_str"
		fi
	fi

}

# When the script uni-system-prog.sh is sent the EXIT signal, this function will fire and allow a safe shutdown.
function uni_system_shutdown() {

	# Shutting down
	play_wav "default_tone"
	$speak "Uni System shutting down"

	wait

}

# Get the machines details such as the machine name, group(s) it is in, etc.
function gather_machine_details() {

		# Get the name, set vars
		#currently just using the shell hostname.
		uni_machine_name=$(echo "$HOSTNAME")

		# I need to setup functions to add and remove groups from this array.
		# By default, machines will be in the "all" group so we can address all of them if need be.
			#[bob in ~] ARRAY=(one two three)
			#[bob in ~] echo ${ARRAY[*]}
				#one two three
			#[bob in ~] echo $ARRAY[*]
				#one[*]
			#[bob in ~] echo ${ARRAY[2]}
				#three
			#[bob in ~] ARRAY[3]=four
			#[bob in ~] echo ${ARRAY[*]}
				#one two three four

			# I should be getting these from the DataBase....Put there on setup/install.
			uni_machine_groups=(all)
}


function text2speech() {

	INPUT=$*
	STRINGNUM=0
	ary=($INPUT)
	mplayer_var=$(loc_file "mplayer" "/usr/local")
	# if mplayer is not found(like in a server enviroment) exit the function.
	# We should also set a flag variable allowing us to know to skip this function altogether in the first place, next time around.

	# Nothing found for mplayer
	if [ "$mplayer_var" == "" ]; then
		#exit -21
		return
	else
		add_to_cache_loc_file "mplayer" "$mplayer_var" # Add it the cache.
	fi

	for key in "${!ary[@]}"
	do
		SHORTTMP[$STRINGNUM]="${SHORTTMP[$STRINGNUM]} ${ary[$key]}"
		LENGTH=$(echo ${#SHORTTMP[$STRINGNUM]})

		if [[ "$LENGTH" -lt "100" ]]; then

			SHORT[$STRINGNUM]=${SHORTTMP[$STRINGNUM]}
		else
			STRINGNUM=$(($STRINGNUM+1))
			SHORTTMP[$STRINGNUM]="${ary[$key]}"
			SHORT[$STRINGNUM]="${ary[$key]}"
		fi
	done

	for key in "${!SHORT[@]}"
	do
		say() { local IFS=+; $mplayer_var -nolirc -ao alsa -really-quiet -noconsolecontrols "http://translate.google.com/translate_tts?tl=en&q=${SHORT[$key]}"; }
		#say() { local IFS=+; $mplayer_var -nolirc -ao alsa -noconsolecontrols "http://translate.google.com/translate_tts?tl=en&q=${SHORT[$key]}"; }

		say $*
	done

}

####
# Setup some constants
####

# Declare some variables for global use
declare -Ag cache_arr # For the cache in loc_file, add_to_cache_loc_file functions
declare -g loc_file_in_cache="false"
declare -g in_array_key=""
declare -g in_array_val=""
declare -g cache_loaded_from_disk="false"
declare -g unisystem_functions_online="false"

####
# Source other functions
####
	#echo "Finding DB."
	uni_db=$(loc_file "uni_sqlite_db_functions.sh")
	add_to_cache_loc_file "uni_sqlite_db_functions.sh" "${uni_db}" # Add it the cache.
	#uni_db=$(loc_file "wolf.wav")
	#echo "Sourcing the DB -> $uni_db"
	#source "${uni_db}"
	#echo "DB Done."

# UniSystem Online. Don't bother reloading
unisystem_functions_online="true"

# The following are optional. If you code your script to use these variable, turn them on.
# If not, copy the code below into your scripts. If you do that, your system will be for dynamic. If you do not, you may have to rerun or restart some things to get the latest location into the variable

# Tell the world that we are alive !
text2speech "UniSystem Online"
