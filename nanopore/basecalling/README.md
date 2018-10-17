## Guide to run albacore in Beocat at K-State
### INSTALLATION
1. Download a new version of albacore from Nanopore community. Select the Python3.6 version.
2. Create a virtual environment
```
module load Python/3.6.4-foss-2018a  # the version of Python is subject to change
mkdir ~/virtualenvs
cd ~/virtualenvs
virtualenv python3.6.4 # python3.6.4 can be any name
```
3. install albacore
```
source ~/virtualenvs/python3.6.4/bin/activate
pip3 install <path-to-downloaded_albacore_package>
deactivate
```
### Base calling
Run the script *albacore.basecall.sbatch* for base calling.
First, set slurm run parameters in the script.
```
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-292:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --partition=ksu-plantpath-liu3zhen.q,batch.q,killable.q
```

Second, change data information in the script
```
# base calling with albacore
datadir=/bulk/liu3zhen/LiuRawData/nanopore/A188WGS181010A/  # directory saving data
outname=albacore.python3.6.4
nthreads=16  # need to be consistent with SBATCH parameters

flowcell=FLO-MIN106
kit=SQK-LSK109
outfmt=fastq
fast5dir=$datadir"/fast5/pass"
```

Third, run the script
```
sbatch albacore.basecall.sbatch
```
