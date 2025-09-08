#!/bin/bash

# Copy the .sh file from ./templates,
# and modify its content

TEMPLATE="./templates/template_batch.sh"
BATCH_FILE="./batch_rapid.sh"
cp "$TEMPLATE" "$BATCH_FILE"
BASE_DIR="$(pwd)"
CMD_CONF="$BASE_DIR/cmd_RAPID.conf"

sed -i "s|^srun .*|srun -l -o $BASE_DIR/logs/RAPID_v2-%j-%t.out --multi-prog $CMD_CONF|" "$BATCH_FILE"
