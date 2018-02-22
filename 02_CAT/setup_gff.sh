#make GFF

#download Ensembl 91 GFF file
wget ftp://ftp.ensembl.org/pub/release-91/gff3/gallus_gallus/Gallus_gallus.Gallus_gallus-5.0.91.gff3.gz
gunzip Gallus_gallus.Gallus_gallus-5.0.91.gff3.gz

#get assembly report
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/315/GCF_000002315.4_Gallus_gallus-5.0/GCF_000002315.4_Gallus_gallus-5.0_assembly_report.txt

#make chr translation table for gffread
grep "assembled-molecule" GCF_000002315.4_Gallus_gallus-5.0_assembly_report.txt | cut -f3,7 > chr_conv_table
grep -v "assembled-molecule" GCF_000002315.4_Gallus_gallus-5.0_assembly_report.txt | grep -v "^#" | cut -f 5,7 >> chr_conv_table

#translate
gffread Gallus_gallus.Gallus_gallus-5.0.91.gff3 -m chr_conv_table -o temp.gff

#remove gffread header
grep -v "^# " temp.gff > galGal5-filtered.gff

#cleanup
rm temp.gff
