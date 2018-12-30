### DiscovarDenovo

#### DiscoverDenovo installation in Beocat

Dependancy - jemalloc
```
# jemalloc (version 5.1.0)
install_dir=/homes/liu3zhen/local
wget https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2
tar -xf jemalloc-5.1.0.tar.bz2 
cd jemalloc-5.1.0
./configure --prefix=$install_dir
make
make install
```
DiscovarDenovo
```
# download the latest DiscovarDenovo and enter into the directory
wget ftp://ftp.broadinstitute.org/pub/crd/DiscovarDeNovo/latest_source_code/discovardenovo-52488.tar.gz
tar -xf discovardenovo-52488.tar.gz
cd discovardenovo-52488
./configure --prefix=/homes/liu3zhen/local --with-jemalloc=/homes/liu3zhen/local/lib
make all
make install
```
