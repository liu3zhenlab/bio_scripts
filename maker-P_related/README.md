## maker-P

## Repeats

### Bio::perl
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
# requirements
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
