#4d sites for brood parasite projects

#setup
module purge
source activate py27
module load hal/20160415-fasrc01
module load bedtools2/2.26.0-fasrc01
module load cufflinks/2.2.1-fasrc01
module load kentUtils/358-fasrc01

#get taeGut annotation from NCBI:

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/151/805/GCF_000151805.1_Taeniopygia_guttata-3.2.4/GCF_000151805.1_Taeniopygia_guttata-3.2.4_genomic.gff.gz
gunzip GCF_000151805.1_Taeniopygia_guttata-3.2.4_genomic.gff.gz

#make CDS-only gff
gffread --no-pseudo -C -T -o - GCF_000151805.1_Taeniopygia_guttata-3.2.4_genomic.gff | grep "protein_coding" | grep -P "\tCDS\t" > taeGut_filt.gtf

gtfToGenePred taeGut_filt.gtf taeGut.ncbi.gp
genePredToBed taeGut.ncbi.gp taeGut.cds.bed

#run phylo4d from haltools

halPhyloPTrain.py --numProc 12 --noAncestors --substMod SSREV ../work/broodParaAlign.hal \
--tree "(galGal(colLiv((calAnn,cucCan),(falPer,(corCor,((parMaj,pseHum),(ficAlb,((serCan,(pasDom,(zonAlb,((molAte,agePho),setCor)))),(vidMac,taeGut1)))))))));" \
--targetGenomes "galGal,colLiv,calAnn,cucCan,falPer,corCor,parMaj,pseHum,ficAlb,serCan,pasDom,zonAlb,molAte,agePho,setCor,vidMac,taeGut1" \
taeGut1 taeGut.cds.bed bp_neut_4d.mod

#will need to rerun/parse this to include only a single taeGut before final runs
