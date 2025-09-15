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



### 2. Modify `run_rapid.conf` and files in `templates/`

Edit the following lines in `run_rapid.conf`:


```bash

CONTROL_FOLDER="/tank/data/SFS/xinyis/shared/data/RAPID_test/2022/case_20220501"

```

Path to the folder to place the control file.

This script will automaticlly generate the corresponding `RAPID.project` file in that folder.

The RAPID results will also be in that folder.


```bash

INPUT_FOLDER="/tank/data/SFS/xinyis/shared/data/RAPID_test/2022/case_20220501"

```

The images to be processed are in this folder.


```bash

FILE_ID_MAX=1

```

Number of images to process.  

RAPID will automatically run from the **first image** up to `FILE_ID_MAX`.

Do **not** modify paths of `.sh` and `.conf` files for now.

They are copied from the `templates/` folder, and will be here as default.

Make sure the `sbatch` parameters and file paths are correct in the files in `templates/` folder.



---



### 3. Submit the Job

Run the following command:



```bash

cd RAPID-2.0-Test-Chain

sbatch slurm_submit.sh

```

Make sure you are in the `RAPID-2.0-Test-Chain` folder when submit the job.

Change the `sbatch` parameters as needed.



---



## Contact

For errors and questions, please reach out:  

**maopuxu@uwm.edu**



