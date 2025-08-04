#!/bin/bash

#SBATCH --output=/home/uwm/maopuxu/rapid_test_chain_%j.out

CMD_CONF="/home/uwm/maopuxu/RAPID_script/cmd_RAPID.conf"
CONTROL_FILE="/tank/data/SFS/xinyis/shared/data/RAPID_test/2022/case_20220501/case_20220501.project"
FILE_ID_MAX=1
LOG_FOLDER="logs"

declare -a POLS=("\"VV\"" "\"VH\"" "\"VV\",\"VH\"" "\"VV\",\"VH\"")
declare -a TASKS=("\"binary_classify\"" "\"binary_classify\"" "\"morph_pre\"" "\"morph\"")

file_id=1
while [ "$file_id" -le "$FILE_ID_MAX" ]; do
    # Modify the cmd file
    ./modify_cmd_conf.sh "$CMD_CONF" "$CONTROL_FILE" "$file_id"
    echo -e "\nProcess image number $file_id ... \n\n"
    ((file_id++))

    i=0
    while [ "$i" -le 3 ]; do
        restart=0
        POL=${POLS[$i]}
        TASK=${TASKS[$i]}
        rm "$LOG_FOLDER"/*

        echo "=== [Run $((i+1))] TaskType=$TASK | Polarization=$POL ==="

        # Modify the project file
        ./modify_project_file.sh "$CONTROL_FILE" "$POL" "$TASK"

        # Submit the job
        JOB_ID=$(sbatch --parsable batch_rapid.sh)
        LOG_FILE="slurm-${JOB_ID}.out"
        date
        echo "Submitted job ${JOB_ID}"
        sleep 10

        # Start time tracking
        echo "Waiting for job ${JOB_ID} to complete..."
        START_TIME=$(date +%s)
        minutes=0
        image_failed=0
        while :; do
            STATUS=$(squeue --job "$JOB_ID" --format="%T")
            STATUS=$(echo $STATUS | awk '{print $2}')
            #echo $STATUS

            if [ -z "$STATUS" ]; then
                END_TIME=$(date +%s)
                ELAPSED=$(( (END_TIME - START_TIME) / 60 ))

                if grep -q "exit code 0" "$LOG_FILE"; then
                    echo "Job ${JOB_ID} finished successfully after ${ELAPSED} min."
                elif grep -q "CANCELLED" "$LOG_FILE"; then
                    echo "Job cancelled, continue on ..."
                elif grep -q "error" "$LOG_FILE"; then
                    echo "Job ${JOB_ID} failed after ${ELAPSED} min."
                    date
                    echo "This imgae failed."
                    #exit 1
                    image_failed=1
                else
                    date
                    echo "Job ended with some reason."
                    exit 1
                fi

                rm "$LOG_FILE"
                break
            elif [ "$STATUS" == "PENDING" ]; then
                echo "Job ${JOB_ID} is pending."
                # Do not include pending time
                minutes=0
            elif [ "$STATUS" == "RUNNING" ]; then
                # Look for failed cores in logs
                for file in "$LOG_FOLDER"/*.out; do
                    #echo "Checking $file..."
                    if grep -qi "sufficient initialization windows" "$file"; then
                        echo "Cannot continue due to insufficient initialization windows."
                        scancel $JOB_ID
                        rm "$LOG_FILE"
                        #exit 1
                        image_failed=1
                    elif grep -qi "ALL_DONE_FLAG" "$file"; then
                        echo "Finish flag detected ..."
                        echo "Cancel job and continue (NO RERUN PREVIOUS TASK)"
                        restart=1
                        ((i++))  # Do not rerun the previous task
                        break
                    elif grep -qi "error" "$file"; then
                        echo "Error found in $file"
                        echo "================"
                        tail -n 20 "$file"
                        echo "================"
                        echo "Rerun the previous task ..."
                        restart=1
                        break
                    fi
                done

                # If this image failed with some reason
                if [ $image_failed == 1 ]; then
                    rm "$LOG_FILE"
                    break
                fi

                # If running time is too long
                if [ "$minutes" -ge 200 ]; then
                    restart=1
                    echo "Running time is too long"
                    echo "Rerun the previous task ..."
                fi

                # Set to rerun the previous task
                if [ $restart == 1 ]; then
                    ((i--))
                    scancel $JOB_ID
                    sleep 5
                    rm "$LOG_FILE"
                    break
                fi
            fi

            sleep 60
            ((minutes++))
            echo "Job ${JOB_ID} still running... ${minutes} min passed."
        done

        if [ $image_failed == 1 ]; then
            echo "Continue to the next image ..."
            break
        fi

        ((i++))
    done
done

echo "All done!"
