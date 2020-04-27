#!/bin/bash
#SBATCH -p shared
#SBATCH -n 8
#SBATCH -N 1
#SBATCH -t 2-00:00
#SBATCH --mem 16000
#SBATCH --array 0-464

source ~/sw/bin/prepPhyloAcc.sh
PhyloAcc control_param/run${SLURM_ARRAY_TASK_ID}

