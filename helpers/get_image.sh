#!/bin/bash

# Return the path of images to be processed
# by reading the txt file in the given path

PATH_TODAY="${1}/$(date -d "yesterday" +%F)"

if [ -d "$PATH_TODAY" ]; then
    file=$(find "$PATH_TODAY" -type f -name "*.txt" | head -n 1)
    if [ -f "$file" ]; then
        head -n 1 "$file"
    else
	echo ""
    fi
else
    echo ""
fi

