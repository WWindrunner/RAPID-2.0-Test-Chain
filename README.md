# RAPID Processing Chain Script (UWM HPC)



This repository provides a script for running **RAPID 2.0** on the UWM HPC cluster.  

It automates the workflow by setting parameters and paths, so you don’t need to run every step manually.  



The script requires **SLURM** since it submits RAPID jobs and monitors job status via SLURM commands.



---



## Setup & Run



### 1. Prepare RAPID 2.0

- Make sure **RAPID 2.0** is installed and working correctly.  

- Test the 3 steps separately before running the chain:

&nbsp; 1. **Binary classification**

&nbsp; 2. **morph_pre**

&nbsp; 3. **morph**



---



### 2. Modify `run_rapid.conf` and `slurm_submit.sh`

Edit the following lines:



```bash

#SBATCH --output=/home/uwm/maopuxu/rapid_test_chain_%j.out

```

Path to the **output log file**.  

Must be outside the `RAPID-2.0-Test-Chain` folder to avoid errors.



```bash

BATCH_FILE="/home/uwm/maopuxu/RAPID_script/batch_rapid.sh"

```

Path to the RAPID **submission script** (`.sh` file).



```bash

CMD_CONF="/home/uwm/maopuxu/RAPID_script/cmd_RAPID.conf"

```

Path to the RAPID **configuration file** (`.conf`).



```bash

CONTROL_FILE="/tank/data/SFS/xinyis/shared/data/RAPID_test/2022/case_20220501/case_20220501.project"

```

Path to the RAPID **project file** (`.project`).



```bash

FILE_ID_MAX=1

```

Number of images to process.  

RAPID will automatically run from the **first image** up to `FILE_ID_MAX`.



---



### 3. Submit the Job

Run the following command:



```bash

sbatch run_rapid.sh

```



---



## Contact

For errors and questions, please reach out:  

**maopuxu@uwm.edu**



