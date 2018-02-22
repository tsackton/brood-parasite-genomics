#code to extract CNEE alignments from hal file
#use same approach as ratite project

#setup
module purge
source activate py27
module load hal/20160415-fasrc01
module load bedtools2/2.26.0-fasrc01
module load cufflinks/2.2.1-fasrc01
module load kentUtils/358-fasrc01

#get psl files

for SP in galGal colLiv calAnn cucCan falPer corCor parMaj pseHum ficAlb serCan pasDom zonAlb molAte agePho setCor vidMac taeGut1 taeGut_dip
do
	halLiftover --outPSLWithName ../../01_alignment/work/broodParaAlign.hal taeGut1 ../concat_cnees/taeGut1_final_merged_CNEEs_named.bed $SP $SP.psl &
done

#run ratite scripts (with slight modifications)
wget https://raw.githubusercontent.com/tsackton/ratite-genomics/master/07_cnee_analysis/00_make_cnee_aligns/parse_cnee_halLiftover.pl

#change file names and list of non-reference genomes, also allow length up to 250%
#run parse_cnee scripts
perl parse_cnee_halLiftover.pl 

#some qc
grep "multiple_liftover_regions" final_cnees_long_liftover_parsing_log | cut -f1,1 | sort | uniq -c | sed "s/^[ \t]*//"  > multiple_liftovers_byCNEE.log
grep "no_liftover" final_cnees_long_liftover_parsing_log | cut -f1,1 | sort | uniq -c | sed "s/^[ \t]*//" > no_liftOver_byCNEE.log


#different approach to making input to mafft; use bedtools getfasta to get a fasta file for each species with an entry for each CNEE; then split and merge by CNEE name; output should be one file per CNEE with fasta header = species (instead of one file per species with fasta header = CNEE)

for SP in galGal colLiv calAnn cucCan falPer corCor parMaj pseHum ficAlb serCan pasDom zonAlb molAte agePho setCor vidMac taeGut1 taeGut_dip
do
	bedtools getfasta -name -fi ../../../DATA/01_alignment/input_seqs/$SP.fa.filt1kb -bed ${SP}_cnees_parsed_liftover.bed -name -s > $SP.cnees.fa &
done

#use bioawk to fix up -- this is kind of hacky but should work without generating tons of intermediate files
for SP in galGal colLiv calAnn cucCan falPer corCor parMaj pseHum ficAlb serCan pasDom zonAlb molAte agePho setCor vidMac taeGut1 taeGut_dip
do
	bioawk -c fastx '{gsub(/::.*$/,"",$name); print "'"$SP"'", $name, $seq}' $SP.cnees.fa >> all_cnees.tab
done

#check

(py27)[tsackton@bioinf01 extract_cnee_aligns]$ cut -f1,1 all_cnees.tab | sort | uniq -c
 905316 agePho
 829670 calAnn
 872429 colLiv
 916304 corCor
 871963 cucCan
 902262 falPer
 898781 ficAlb
 833293 galGal
 895105 molAte
 921030 parMaj
 916158 pasDom
 921727 pseHum
 916413 serCan
 899003 setCor
 929987 taeGut1
 895782 taeGut_dip
 911902 vidMac
 910939 zonAlb
 
(py27)[tsackton@bioinf01 extract_cnee_aligns]$ wc -l *.bed
   905316 agePho_cnees_parsed_liftover.bed
   829670 calAnn_cnees_parsed_liftover.bed
   872429 colLiv_cnees_parsed_liftover.bed
   916304 corCor_cnees_parsed_liftover.bed
   871963 cucCan_cnees_parsed_liftover.bed
   902262 falPer_cnees_parsed_liftover.bed
   898781 ficAlb_cnees_parsed_liftover.bed
   833293 galGal_cnees_parsed_liftover.bed
   895105 molAte_cnees_parsed_liftover.bed
   921030 parMaj_cnees_parsed_liftover.bed
   916158 pasDom_cnees_parsed_liftover.bed
   921727 pseHum_cnees_parsed_liftover.bed
   916413 serCan_cnees_parsed_liftover.bed
   899003 setCor_cnees_parsed_liftover.bed
   929987 taeGut1_cnees_parsed_liftover.bed
   895782 taeGut_dip_cnees_parsed_liftover.bed
   911902 vidMac_cnees_parsed_liftover.bed
   910939 zonAlb_cnees_parsed_liftover.bed


#now convert back to fasta by column 2 (this will make 900000 files)
awk '{print ">"$1 >> "unaligned/"$2".fa"; print $3 >> "unaligned/"$2".fa"; close("unaligned/"$2".fa")}' all_cnees.tab

#at this stage we have a fasta for each CNEE

#make list of all CNEE ids
mkdir -p aligned
cut -f4,4 taeGut1_cnees_parsed_liftover.bed | split -a 3 -d  -l 1000 - batch
mv batch* aligned

#now run run_mafft.sh script

#once we have an alignment for each CNEE, use amas https://github.com/marekborowiec/AMAS to concatenate and produce partition file, which can easily be converted to bed format