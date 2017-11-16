#!/bin/bash

# Examples:
#	find_up.sh some_dir -iname "foo*bar" -execdir pwd \;
#	find_up.sh . -name "uni_functions.sh"

set -e
path="$1"
shift 1
while [[ "$path" != "/" ]];
do
    find "$path"  -maxdepth 1 -mindepth 1 "$@"
    path="$(readlink -f $path/..)"
done
