#!/bin/bash


CONF="$1"
if [ -z "$CONF" ]; then
    echo "Usage: sbatch run_rapid.sh <config_file>"
    exit 1
fi
source "$CONF"

declare -a POLS=("\"VV\"" "\"VH\"" "\"VV\",\"VH\"" "\"VV\",\"VH\"")
declare -a TASKS=("\"binary_classify\"" "\"binary_classify\"" "\"morph_pre\"" "\"morph\"")

# Set log folder in config file
#MAIN_LOG_FOLDER="$(dirname "$CMD_CONF")/logs"
#./helpers/modify_batch_file.sh
mkdir -p "$MAIN_LOG_FOLDER"

# If run in release mode, read in the input folder and set output folder
if [ "$RELEASE_MODE" -eq 1 ]; then
    echo "Program runs in RELEASE mode"
    INPUT_FOLDER=$(./helpers/get_image.sh "$IMAGE_PROCESS_DIR")
    if [ -d "$INPUT_FOLDER" ]; then
	CONTROL_FOLDER="${DAILY_OUTPUT_FOLDER}/$(date -d "yesterday" +%F)"
        FILE_ID_MAX=$(ls -l "$INPUT_FOLDER" | grep ^d | wc -l)
    else
	echo "No input folder detected"
	exit 0
    fi
else
    echo "Program runs in NORMAL mode"
fi
COM_FOLDER="${CONTROL_FOLDER}/com"
mkdir -p "$CONTROL_FOLDER"
mkdir -p "$COM_FOLDER"

file_id=0
while [ "$file_id" -lt "$FILE_ID_MAX" ]; do
    ((file_id++))
    echo -e "\nProcess image number $file_id ... \n\n"
    restart_count=0

    i=0
    while [ "$i" -le 3 ]; do
        restart=0
        POL=${POLS[$i]}
        TASK=${TASKS[$i]}
        #rm -f "$LOG_FOLDER"/*

        echo "=== [Run $((i+1))] TaskType=$TASK | Polarization=$POL ==="

	# Check if this step has been done before
	if [ -f "${COM_FOLDER}/${file_id}_${i}_done.txt" ]; then
	    echo "This task has been done before, move on ..."
	    ((i++))
	    continue
	fi

	# Modify the cmd file
        ./helpers/modify_cmd_conf.sh "$CONTROL_FOLDER" "$file_id" "$RUN_BINARY"
		
        # Modify the project file
        ./helpers/modify_project_file.sh "$INPUT_FOLDER" "$CONTROL_FOLDER" "$POL" "$TASK"

	# Modify the batch file, set log folder here
	LOG_FOLDER="$MAIN_LOG_FOLDER/${TASK//\"/}_${POL//\"/}_$(date +%F-%T)"
	mkdir -p "$LOG_FOLDER"
	rm -f "$LOG_FOLDER"/*
	./helpers/modify_batch_file.sh "$LOG_FOLDER"

        # Submit the job
        JOB_ID=$(sbatch --parsable batch_rapid.sh)
        LOG_FILE="slurm_${JOB_ID}.out"
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
		    # Record finish status in com folder
		    touch "${COM_FOLDER}/${file_id}_${i}_done.txt"
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

                rm -f "$LOG_FILE"
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
                        image_failed=1
			break
                    elif grep -qi "ALL_DONE_FLAG" "$file"; then
                        echo "Finish flag detected ..."
                        echo "Cancel job and continue (NO RERUN PREVIOUS TASK)"
                        restart=1
			touch "${COM_FOLDER}/${file_id}_${i}_done.txt"
                        ((i++))  # Do not rerun the previous task
                        break
                    elif grep -q "Error in" "$file"; then
                        echo "Error found in $file"
                        echo "================"
                        tail -n 25 "$file"
                        echo "================"
                        echo "Rerun the previous task ..."
                        restart=1
                        break
                    fi
                done

                # If this image failed with some reason
                if [ $image_failed == 1 ]; then
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
		    if [ $restart_count == 7 ]; then
			echo "Restarted too many times, skip this image ..."
			image_failed=1
                        break
		    else
			((restart_count++))
		    fi
		    
                    ((i--))
                    scancel $JOB_ID
                    sleep 5
                    rm -f "$LOG_FILE"
                    break
                fi
            fi

            sleep 60
            ((minutes++))
            echo "Job ${JOB_ID} still running... ${minutes} min passed."
        done

        if [ $image_failed == 1 ]; then
            echo "Continue to the next image ..."
	    scancel $JOB_ID
            sleep 5
            rm -f "$LOG_FILE"
            break
        fi

        ((i++))
    done
done

echo "All done!"
