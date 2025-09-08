#!/bin/bash
#SBATCH --job-name=rapid_test_chain
#SBATCH --output=/home/uwm/maopuxu/rapid_test_chain_%j.out
#SBATCH --partition=batch


CONF_FILE="/home/uwm/maopuxu/RAPID_script/run_rapid.conf"

srun run_rapid.sh "$CONF_FILE"
