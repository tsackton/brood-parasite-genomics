#cat

#installation

#conda
module purge
module load Anaconda3/2.1.0-fasrc01 #version I guess shouldn't matter this is just the default I use

#a bunch of Kent tools need newer versions so including them in conda create
conda create -n cat python=2.7 pip pyopenssl bedtools=2.27.0 sambamba wiggletools blat ucsc-psltobigpsl ucsc-pslmappostchain ucsc-gff3togenepred ucsc-bamtopsl ucsc-transmappsltogenepred ucsc-pslcdnafilter


#modules
module load augustus/3.3-fasrc01
module load kentUtils/302.1.0-fasrc01
module load hal/20160415-fasrc01
source activate cat #use conda versions of newer Kent tools
module load samtools/1.5-fasrc01 #make sure we are using the module version of samtools not the conda version

git clone https://github.com/ComparativeGenomicsToolkit/Comparative-Annotation-Toolkit.git
pip install -e Comparative-Annotation-Toolkit

##test data 
cd Comparative-Annotation-Toolkit

#run test
luigi --module cat RunCat --hal=test_data/vertebrates.hal \
  --ref-genome=mm10 --workers=10 --config=test_data/test.config \
  --work-dir test_install --out-dir test_install --local-scheduler \
  --augustus --augustus-cgp --augustus-pb --assembly-hub > log.txt 2> log.err

#setup 
module purge
module load Anaconda3/2.1.0-fasrc01 
module load augustus/3.3-fasrc01
module load kentUtils/358-fasrc01
module load hal/20160415-fasrc01
source activate cat
module load samtools/1.5-fasrc01 

##chainMergeSort causing segfaults, trying to upgrade
