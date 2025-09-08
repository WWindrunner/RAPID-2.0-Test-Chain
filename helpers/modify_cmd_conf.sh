#!/bin/bash

# Copy the .conf file from ./templates,
# and modify its content

NEW_PATH="$1/RAPID.project"
FILE_ID="$2"

ESC_PATH=$(echo "$NEW_PATH" | sed 's/[&/\]/\\&/g')
#echo $ESC_PATH
TEMPLATE="./templates/template_cmd.conf"
CONF_FILE="./cmd_RAPID.conf"
cp "$TEMPLATE" "$CONF_FILE"

sed -i "s/'[^']*\.project/'$ESC_PATH/g" "$CONF_FILE"
sed -Ei "s/',[0-9]+,/',$FILE_ID,/1" "$CONF_FILE"
