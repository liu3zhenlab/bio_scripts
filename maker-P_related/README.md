## maker-P

## Repeats

### Bio::perl and other module using cpanm
```
sudo cpanm Bio::Perl
```

### muscle
```
wget http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz
tar -xf muscle3.8.31_i86linux64.tar.gz
cd /usr/local/bin/
sudo ln -s /home/liu3zhen/software/muscle/muscle3.8.31_i86linux64 muscle
```

### RepeatMask
**requirements**
1. TRF 4.04 or higher ( http://tandem.bu.edu/trf/trf.html )
download trfxxx
```
cd /usr/local/bin
sudo ln -s trfxxx trf
```
2. A search engine.  e.g., rmblast
```
wget http://www.repeatmasker.org/rmblast-2.9.0+-x64-linux.tar.gz
tar -xf rmblast-2.9.0+-x64-linux.tar.gz 
cd rmblast-2.9.0/
# make the path accessible to Repeatmask
```

3. RepeatMasker libraries (The full RepeatMasker Library can be obtained from www.girinst.org)
```
perl ./configure
# and follow the instruction to finish the installation
```

### RepeatModeler
**requirements**
1. RepeatMasker
2. RECON
```
wget http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz
cd RECON-1.08/
cd src/
make
sudo make install
```
3. RepeatScout
```
wget http://www.repeatmasker.org/RepeatScout-1.0.5.tar.gz
tar -xf RepeatScout-1.0.5.tar.gz 
cd RepeatScout-1/
make
# add path to .bash_profile
```
4. NSEG
```
wget ftp://ftp.ncbi.nih.gov/pub/seg/nseg/*
make
# add path to .bash_profile
```

**installation**
```
wget http://www.repeatmasker.org/RepeatModeler/RepeatModeler-open-1.0.11.tar.gz
tar -xf RepeatModeler-open-1.0.11.tar.gz 
cd RepeatModeler-open-1.0.11/
# install missing Perl modules
# for example:
sudo cpanm JSON
perl ./configure 
```
5. snap, augustus, exonerate
```
#wget http://korflab.ucdavis.edu/Software/snap-2013-11-29.tar.gz
#cd snap
#set ZOE path
#make
sudo apt-get install snap

sudo apt-get install exonerate
sudo apt-cache search Augustus
sudo apt-cache search Augustus-data
```

6. Genemark-ES
```
tar -xf gm_et_linux_64.tar.gz 
cd gm_et_linux_64/
cp gm_key_64 ~/.gm_key 
# set path
```

7. maker
Follow maker instruction to install maker.

