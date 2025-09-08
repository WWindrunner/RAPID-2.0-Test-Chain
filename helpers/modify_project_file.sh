#!/bin/bash

CONTROL_FILE="$1"
NEW_POL="$2"
NEW_TASK="$3"

NEW_POL="Polarizations = $NEW_POL"
NEW_TASK="TaskType = $NEW_TASK"

# Update Polarizations
sed -i -r "s/\bPolarizations\s*=\s*.*/$NEW_POL/g" "$CONTROL_FILE"

# Update TaskType
sed -i -r "s/\bTaskType\s*=\s*.*/$NEW_TASK/g" "$CONTROL_FILE"
