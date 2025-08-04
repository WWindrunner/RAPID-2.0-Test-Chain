#!/bin/bash

CONF_FILE="$1"
NEW_PATH="$2"
FILE_ID="$3"

ESC_PATH=$(echo "$NEW_PATH" | sed 's/[&/\]/\\&/g')
#echo $ESC_PATH
sed -i "s/'[^']*\.project/'$ESC_PATH/g" "$CONF_FILE"
sed -i "s/project',\d+,/project',$FILE_ID,/1" "$CONF_FILE"
