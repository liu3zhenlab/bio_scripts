#!/bin/bash -l
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-292:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
##SBATCH --partition=ksu-gen-gpu.q

# load python and use virtual environment
module load Python/3.6.4-foss-2018a
source ~/virtualenvs/python3.6.4/bin/activate
#export PYTHON_LIBRARY=/homes/liu3zhen/virtualenvs/python3/lib/
#export PYTHON_INCLUDE_DIR=/homes/liu3zhen/virtualenvs/python3/include/

# base calling with albacore
datadir=/bulk/liu3zhen/LiuRawData/nanopore/A188WGS181010A/
outname=albacore.python3.6.4
nthreads=16  # need to be consistent with SBATCH parameters

flowcell=FLO-MIN106
kit=SQK-LSK109
outfmt=fastq
fast5dir=$datadir"/fast5/pass"
outdir=$datadir"/"$outname
logfile=$outname".log"

# information to log
read_fast5_basecaller.py -v 1>$logfile 2>/dev/null
echo "Here are parameters used." >>$logfile
echo "============================" >>$logfile
echo "flowcell="$flowcell >>$logfile
echo "kit="$kit >>$logfile
echo "output_format="$outfmt >>$logfile
echo "threads number="$nthreads >>$logfile
echo "input_directory="$fast5dir >>$logfile
echo "output_directory="$outdir >>$logfile

# basecalling
time read_fast5_basecaller.py --flowcell $flowcell --kit $kit --output_format $outfmt --input $fast5dir --save_path $outdir --worker_threads $nthreads

# deactivate virtualenv
#deactivate

