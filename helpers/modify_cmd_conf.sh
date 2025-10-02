#!/bin/bash

# Copy the .conf file from ./templates,
# and modify its content

NEW_PATH="$1/RAPID.project"
FILE_ID="$2"

ESC_PATH=$(echo "$NEW_PATH" | sed 's/[&/\]/\\&/g')
#echo $ESC_PATH
CONF_FILE="./cmd_RAPID.conf"

if [ "$3" -eq 0 ]; then
    TEMPLATE="./templates/template_cmd.conf"
    cp "$TEMPLATE" "$CONF_FILE"

    sed -i "s/'[^']*\.project/'$ESC_PATH/g" "$CONF_FILE"
    sed -Ei "s/',[0-9]+,/',$FILE_ID,/1" "$CONF_FILE"
    sed -Ei "s/,[0-9]+\)/,$(date +%s)\)/1" "$CONF_FILE"
else
    TEMPLATE="./templates/template_cmd_compiled.conf"
    cp "$TEMPLATE" "$CONF_FILE"

    sed -Ei "s|[^[:space:]]+\.project|$ESC_PATH|" "$CONF_FILE"
    sed -Ei "s/([[:space:]])4([[:space:]])/\1${FILE_ID}\2/" "$CONF_FILE"
    sed -Ei "s/[0-9]+$/$(date +%s)/" "$CONF_FILE"
fi
