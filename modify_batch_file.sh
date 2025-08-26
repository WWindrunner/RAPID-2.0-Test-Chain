#!/bin/bash
# Usage: modify_batch_file.sh /a/cmd_RAPID.conf yourfile.txt

CMD_CONF="$1"
FILE="$2"

BASE_DIR=$(dirname "$CMD_CONF")

# Replace the srun line with new values
sed -i "s|^srun .*|srun -l -o $BASE_DIR/logs/RAPID_v2-%j-%t.out --multi-prog $CMD_CONF|" "$FILE"
