#cat
 
#installation -- updating for centos 7

#conda
module purge
module load gcc/7.1.0-fasrc01 
module load Anaconda3/5.0.1-fasrc02

#a bunch of Kent tools need newer versions so including them in conda create
conda create -n cat python=2.7 pip pyopenssl bedtools=2.27.0 sambamba wiggletools blat ucsc-psltobigpsl ucsc-pslmappostchain ucsc-gff3togenepred ucsc-bamtopsl ucsc-transmappsltogenepred ucsc-pslcdnafilter ucsc-clusterGenes

#run through here no errors yet..

#modules
module load augustus/3.3-fasrc02
module load ucsc/20150820-fasrc01
source activate cat

#install haltools and sonLib
git clone https://github.com/ComparativeGenomicsToolkit/hal
git clone https://github.com/ComparativeGenomicsToolkit/sonLib
pushd sonLib && make && popd

#build local hdf5 with C++ API 
DIR=/n/home12/tsackton/sw/progs/CompGenToolkit
mkdir $DIR/hdf5
wget http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/hdf5-1.10.1.tar.gz 
tar xzf hdf5-1.10.1.tar.gz
cd hdf5-1.10.1
./configure --enable-cxx --prefix $DIR/hdf5
make && make install

export PATH=$DIR/hdf5/bin:${PATH}
export h5prefix=-prefix=$DIR/hdf5

#also need to build phast I guess...not sure why module isn't working
wget http://www.netlib.org/clapack/clapack.tgz
tar -xvzf clapack.tgz
mv CLAPACK-3.2.1/ clapack
cd clapack
cp make.inc.example make.inc && make f2clib && make blaslib && make lib
cd ..

#make phast
git clone https://github.com/CshlSiepelLab/phast
cd phast/src
make CLAPACKPATH=/n/home12/tsackton/sw/progs/CompGenToolkit/clapack
cd ../..

#for hal compatiblity

export ENABLE_PHYLOP=1

pushd hal && make && popd

#setup paths
export PATH=/n/home12/tsackton/sw/progs/CompGenToolkit/hal/bin:/n/home12/tsackton/sw/progs/CompGenToolkit/hdf5/bin:/n/home12/tsackton/sw/progs/CompGenToolkit/phast/bin:${PATH}
export PYTHONPATH=/n/home12/tsackton/sw/progs/CompGenToolkit:${PYTHONPATH}

module load samtools/1.5-fasrc01 #make sure we are using the module version of samtools not the conda version

git clone https://github.com/ComparativeGenomicsToolkit/Comparative-Annotation-Toolkit.git
pip install -e Comparative-Annotation-Toolkit

##test data 
cd Comparative-Annotation-Toolkit

#run test
luigi --module cat RunCat --hal=test_data/vertebrates.hal \
  --ref-genome=mm10 --workers=10 --config=test_data/test.config \
  --work-dir test_install --out-dir test_install --local-scheduler \
  --augustus --augustus-cgp --augustus-pb --assembly-hub --binary-mode local > log.txt 2> log.err
  

#setup for running -- this is haltools plus CAT but not progressiveCactus (yet)
module purge
module load gcc/7.1.0-fasrc01 
module load Anaconda3/5.0.1-fasrc02
module load augustus/3.3-fasrc02
module load ucsc/20150820-fasrc01
source activate cat
module load samtools/1.5-fasrc01 
export PATH=/n/home12/tsackton/sw/progs/CompGenToolkit/hal/bin:/n/home12/tsackton/sw/progs/CompGenToolkit/hdf5/bin:/n/home12/tsackton/sw/progs/CompGenToolkit/phast/bin:${PATH}
export PYTHONPATH=/n/home12/tsackton/sw/progs/CompGenToolkit:${PYTHONPATH}

