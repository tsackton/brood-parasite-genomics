#!/bin/bash

#concat
python3 /n/home12/tsackton/envs/py3/lib/python3.5/site-packages/amas/AMAS.py concat \
-i batch*_output/*.aligned.fa \
-f fasta \
-d dna \
-p cnee_part.txt \
-t cnee_concat.fa \
-c 12

#clean up
cat cnee_concat.fa | perl -p -e 's/[?]/-/g' > cnee_concat_gapsFixed.fa
python3 /n/home12/tsackton/envs/py3/lib/python3.5/site-packages/amas/AMAS.py remove \
-i cnee_concat_gapsFixed.fa \
-f fasta \
-d dna \
-x taeGut_dip \
-g final_cnee \
-u fasta \
-c 12

#fix partition file
cat cnee_part.txt | perl -p -e 's/p\d+[_](zfCNEE\d+)=(\d+)-(\d+)/$1\t$2\t$3/' | awk 'BEGIN{OFS="\t"} {print $1, $2-1, $3}' > cnee_part.bed
