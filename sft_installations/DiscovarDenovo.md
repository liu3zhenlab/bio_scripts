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
discovarDenovo
```
# download the latest DiscovarDenovo and enter into the directory
install_dir=/homes/liu3zhen/local
jemalloc_dir=/homes/liu3zhen/local
disc_version=discovardenovo-52488
wget ftp://ftp.broadinstitute.org/pub/crd/DiscovarDeNovo/latest_source_code/$disc_version.tar.gz
tar -xf $disc_version.tar.gz
cd $disc_version
./configure --prefix=$install_dir --with-jemalloc=$jemalloc_dir/lib
make all
make install
```
