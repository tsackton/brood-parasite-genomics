#setup phyloAcc runs
#bp = brood parasites as 'test set'
#control = sister groups as 'test set'

#will run 500 batches of 2000 elements each

#set up batch files
mkdir -p batches
wc -l /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/cnee_part.bed  #get number of elements
shuf -i 0-929917 > batches/full_list #get lines in random order
split -d -a 3 -l 2000 batches/full_list batches/batch #make input files

#set up parameter and output files
mkdir -p bp_param
mkdir -p control_param
mkdir -p bp_out
mkdir -p control_out

for I in $(seq 0 464); 
do
  printf -v BATCH "%03d" $I
  PARTFILE=batches/batch$BATCH
  PREFIX=batch${BATCH}
  cat > bp_param/run$I <<EOF 
PHYTREE_FILE /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/bp_neut_4d.mod
SEG_FILE /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/cnee_part.bed
ALIGN_FILE /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/final_cnee_concat.fa 
RESULT_FOLDER bp_out/
PREFIX $PREFIX
ID_FILE $PARTFILE
CHAIN 1
BURNIN 1000
MCMC 4000
CONSERVE_PRIOR_A 4
CONSERVE_PRIOR_B 0.05
ACCE_PRIOR_A 7
ACCE_PRIOR_B 0.3
HYPER_GRATE_A 9
HYPER_GRATE_B 1
TARGETSPECIES molAte;vidMac;cucCan
CONSERVE galGal;agePho;falPer;colLiv;taeGut1;calAnn;corCor;parMaj;ficAlb;serCan;setCor;pasDom;zonAlb
GAPCHAR -
NUM_THREAD 8
VERBOSE 0
CONSTOMIS 1
GAP_PROP 0.999
TRIM_GAP_PERCENT 0.9
EOF
  cat > control_param/run$I <<EOF 
PHYTREE_FILE /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/bp_neut_4d.mod
SEG_FILE /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/cnee_part.bed
ALIGN_FILE /n/holylfs/LABS/informatics/tsackton/broodParasites/DATA/04_phyloAcc/input_data/final_cnee_concat.fa 
RESULT_FOLDER control_out/
PREFIX $PREFIX
ID_FILE $PARTFILE
CHAIN 1
BURNIN 1000
MCMC 4000
CONSERVE_PRIOR_A 4
CONSERVE_PRIOR_B 0.05
ACCE_PRIOR_A 7
ACCE_PRIOR_B 0.3
HYPER_GRATE_A 9
HYPER_GRATE_B 1
TARGETSPECIES agePho;taeGut1;calAnn
CONSERVE galGal;molAte;falPer;colLiv;cucCan;vidMac;corCor;parMaj;ficAlb;serCan;setCor;pasDom;zonAlb
GAPCHAR -
NUM_THREAD 8
VERBOSE 0
CONSTOMIS 1
GAP_PROP 0.999
TRIM_GAP_PERCENT 0.9
EOF
done



