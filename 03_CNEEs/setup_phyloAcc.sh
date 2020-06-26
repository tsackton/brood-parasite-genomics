#setup phyloAcc runs
#bp = brood parasites as 'test set'
#control = sister groups as 'test set'

#will run 500 batches of 2000 elements each

#set up batch files
mkdir -p batches
wc -l cnee_part.bed  #get number of elements
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
PHYTREE_FILE bp_neut_4d.mod
SEG_FILE cnee_part.bed
ALIGN_FILE final_cnee_concat.fa 
RESULT_FOLDER bp_out/
PREFIX $PREFIX
ID_FILE $PARTFILE
BURNIN 500
MCMC 2000
CHAIN 1
TARGETSPECIES molAte;vidMac;cucCan
CONSERVE agePho;falPer;colLiv;taeGut1;calAnn;corCor;parMaj;ficAlb;serCan;setCor;pasDom;zonAlb;galGal
GAPCHAR -
NUM_THREAD 8
VERBOSE 0
EOF
  cat > control_param/run$I <<EOF 
PHYTREE_FILE bp_neut_4d.mod
SEG_FILE cnee_part.bed
ALIGN_FILE final_cnee_concat.fa 
RESULT_FOLDER control_out/
PREFIX $PREFIX
ID_FILE $PARTFILE
BURNIN 500
MCMC 2000
CHAIN 1
TARGETSPECIES agePho;taeGut1;calAnn
CONSERVE molAte;falPer;colLiv;cucCan;vidMac;corCor;parMaj;ficAlb;serCan;setCor;pasDom;zonAlb;galGal
GAPCHAR -
NUM_THREAD 8
VERBOSE 0
EOF
done


