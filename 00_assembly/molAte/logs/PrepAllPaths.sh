#!/bin/bash

#SBATCH -p general                # partition (queue)
#SBATCH -N 1                      # number of nodes
#SBATCH -n 4                     # number of cores
#SBATCH --mem 100000        # memory pool for each cores
#SBATCH -t 1-0:00                 # time (D-HH:MM)
#SBATCH -o PrepAllPaths.out        # STDOUT
#SBATCH --mail-type=ALL           # notifications for job
#SBATCH --mail-user=jdacosta@oeb.harvard.edu   # send-to address
module load legacy/0.0.1-fasrc01
module load centos6/allpathslg-50081
PrepareAllPathsInputs.pl DATA_DIR=/n/regal/mathews_lab/Molothrus_ater/Molothrus_trim/AllPaths IN_GROUPS_CSV=in_groups.csv IN_LIBS_CSV=in_libs.csv PLOIDY=2 HOSTS=4 JAVA_MEM_GB=50 OVERWRITE=True
