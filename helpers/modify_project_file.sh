#!/bin/bash

# Copy the .project file from ./templates,
# and modify its content based on the input folder

INPUT_DIR="$1"
TARGET_DIR="$2"
NEW_POL="$3"
NEW_TASK="$4"

NEW_POL="Polarizations = $NEW_POL"
NEW_TASK="TaskType = $NEW_TASK"
NEW_DIROUT="dirOut = \"$TARGET_DIR/rapid_results\""
NEW_DIRLOC="dirLoc = \"$TARGET_DIR/rapid_results\""
NEW_POLSAR="PolSAR = \"$INPUT_DIR\""

TEMPLATE="./templates/template_config.project"
CONTROL_FILE="$TARGET_DIR/RAPID.project"
cp "$TEMPLATE" "$CONTROL_FILE"

sed -i -r "s/\bPolarizations\s*=\s*.*/$NEW_POL/g" "$CONTROL_FILE"
sed -i -r "s/\bTaskType\s*=\s*.*/$NEW_TASK/g" "$CONTROL_FILE"
sed -i -r "s|\bdirOut\s*=\s*.*|$NEW_DIROUT|" "$CONTROL_FILE"
sed -i -r "s|\bdirLoc\s*=\s*.*|$NEW_DIRLOC|" "$CONTROL_FILE"
sed -i -r "s|\bPolSAR\s*=\s*.*|$NEW_POLSAR|" "$CONTROL_FILE"

