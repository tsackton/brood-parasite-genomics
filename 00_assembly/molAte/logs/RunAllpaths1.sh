#!/bin/bash

#SBATCH -p bigmem                # partition (queue)
#SBATCH -N 1                      # number of nodes
#SBATCH -n 64                     # number of cores
#SBATCH --mem 450000        # memory pool for each cores
#SBATCH -t 10-00:00                 # time (D-HH:MM)
#SBATCH -o RunAllpaths1.out        # STDOUT
#SBATCH --mail-type=ALL           # notifications for job
#SBATCH --mail-user=jdacosta@oeb.harvard.edu   # send-to address
module load legacy
module load centos6/allpathslg-50081
RunAllPathsLG PRE=/n/regal/mathews_lab/Molothrus_ater DATA_SUBDIR=AllPaths RUN=trim REFERENCE_NAME=Molothrus_trim TARGETS=standard EVALUATION=BASIC VAPI_WARN_ONLY=True HAPLOIDIFY=True OVERWRITE=True THREADS=64
