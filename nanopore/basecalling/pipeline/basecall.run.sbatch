#!/bin/bash -l
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-292:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --partition=ksu-gen-gpu.q,ksu-plantpath-liu3zhen.q,batch.q,killable.q
runname=$1
script_dir=/homes/liu3zhen/scripts/nanopore/
rundir=/bulk/liu3zhen/LiuRawData/nanopore/fast5/macJie/$runname
outdir=/bulk/liu3zhen/LiuRawData/nanopore/fastq/macJie/
bash $script_dir/basecall.module.bash -d $rundir -o $outdir

