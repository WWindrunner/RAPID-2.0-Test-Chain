#!/bin/bash

#SBATCH --partition=batch
#SBATCH --mem-per-cpu=4G	
#SBATCH --ntasks=150


echo "Job started"

source /home/uwm/maopuxu/.bashrc
cd /home/uwm/maopuxu/water_body_extraction/RAPID/

srun -l -o /home/uwm/maopuxu/RAPID_script/logs/RAPID_v2-%j-%t.out --multi-prog /home/uwm/maopuxu/RAPID_script/cmd_RAPID.conf

status=$?
if [ $status -eq 0 ]; then
    echo "Job finished successfully with exit code 0"
else
    echo "Job failed with exit code $status"
fi
