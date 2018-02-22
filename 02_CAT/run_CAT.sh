##running CAT

#setup modules
module purge
module load Anaconda3/2.1.0-fasrc01 
module load augustus/3.3-fasrc01
module load kentUtils/358-fasrc01
module load hal/20160415-fasrc01
source activate cat
module load samtools/1.5-fasrc01 

luigi --module cat RunCat \
  --hal=/n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/01_alignment/work/broodParaAlign.hal \
  --ref-genome=galGal \
  --workers=24 \
  --config=/n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/03_CAT/cat.config \
  --target-genomes='("agePho", "calAnn", "colLiv", "corCor", "cucCan", "falPer", "ficAlb", "molAte", "parMaj", "pasDom", "pseHum", "serCan", "setCor", "taeGut1", "vidMac", "zonAlb")' \
  --work-dir bp_CAT_work \
  --out-dir bp_CAT_out \
  --local-scheduler \
  --augustus \
  --augustus-species=chicken \
  --augustus-cgp \
  --maf-chunksize 850000 \
  --maf-overlap 250000 \
  --augustus-pb \
  --maxCores=150 \
  --batchSystem=slurm \
  --assembly-hub > log_stdout.log 2> log_stderr.log
