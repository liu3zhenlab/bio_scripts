#### ALLPATHS-LG
```
inst_path=/homes/liu3zhen/local
wget ftp://ftp.broadinstitute.org/pub/crd/ALLPATHS/Release-LG/latest_source_code/LATEST_VERSION.tar.gz
tar -xf LATEST_VERSION.tar.gz 
cd allpathslg-52488/
./configure --prefix $inst_path
make
make install
```
