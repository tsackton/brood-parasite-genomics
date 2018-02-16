mkdir -p /n/holylfs/LABS/informatics/tsackton/broodParaAlign/cactus_tmp
export TMPDIR=/n/holylfs/LABS/informatics/tsackton/broodParaAlign/cactus_tmp
/n/sw/progressiveCactus/bin/runProgressiveCactus.sh \
	/n/holylfs/LABS/informatics/tsackton/broodParaAlign/seq_file \
	/n/holylfs/LABS/informatics/tsackton/broodParaAlign/work \
	/n/holylfs/LABS/informatics/tsackton/broodParaAlign/work/broodParaAlign.hal \
	--batchSystem=slurm \
	--slurm-partition=general \
	--slurm-jobname=broodParaAlign \
	--slurm-scriptpath='/n/holylfs/LABS/informatics/tsackton/broodParaAlign/slurm' \
	--slurm-time=1440 \
	--slurm-constraint='holyib' \
	--defaultMemory=6000000000 \
	--bigMemoryThreshold=16000000000 \
	--retryCount=3 \
	--bigBatchSystem=singleMachine \
	--configFile=config.xml \
        --maxThreads=16 \
