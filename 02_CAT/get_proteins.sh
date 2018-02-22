wget ftp://ftp.ensembl.org/pub/release-91/fasta/taeniopygia_guttata/pep/Taeniopygia_guttata.taeGut3.2.4.pep.all.fa.gz
wget ftp://ftp.ensembl.org/pub/release-91/fasta/meleagris_gallopavo/pep/Meleagris_gallopavo.UMD2.pep.all.fa.gz
wget ftp://ftp.ensembl.org/pub/release-91/fasta/gallus_gallus/pep/Gallus_gallus.Gallus_gallus-5.0.pep.all.fa.gz
wget ftp://ftp.ensembl.org/pub/release-91/fasta/ficedula_albicollis/pep/Ficedula_albicollis.FicAlb_1.4.pep.all.fa.gz
wget ftp://ftp.ensembl.org/pub/release-91/fasta/anas_platyrhynchos/pep/Anas_platyrhynchos.BGI_duck_1.0.pep.all.fa.gz
gunzip *all.fa.gz
cat *all.fa > proteins.fa
rm *all.fa
