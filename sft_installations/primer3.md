### Installation of primer3 in Ubuntu
```
sudo apt-get install primer3
```
The associated configure files are located at "/etc/primer3_config/"

### Instalation of primer3 in CentOS (slurm system)
```
primer3ver=2.3.7
wget  https://sourceforge.net/projects/primer3/files/primer3/$primer3ver/primer3-$primer3ver.tar.gz
tar -xf primer3-$primer3ver.tar.gz 
cd primer3-$primer3ver
cd src/
make
```
In my installation at K-State Beocat, the configure directory is at "/homes/liu3zhen/software/primer3/primer3-2.3.7/src/primer3_config"
