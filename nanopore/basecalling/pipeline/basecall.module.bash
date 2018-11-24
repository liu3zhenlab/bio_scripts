#!/bin/bash -l
# Sanzhen Liu
# 11/24/2018

# color setting
RED='\033[0;31m'
NC='\033[0m' # No Color

# usage informaiton
usage() {
	echo -e "${RED}Usage${NC}: $0 -d <path_to_run> -o <path_to_output> [other options]" >&2
	echo "	-p: python module; refer the following Github guide for setting" >&2
	echo "      https://github.com/liu3zhenlab/bio_scripts/tree/master/nanopore/basecalling" >&2
	echo "      default=Python/3.6.4-foss-2018a" >&2
	echo "	-a: <full_path/activate>; provide full path to the file of activate" >&2
	echo "      default=/homes/liu3zhen/virtualenvs/python3.6.4/bin/activate" >&2
	echo "	-d: path to Nanopore running directory, required" >&2
	echo "      example: /bulk/liu3zhen/LiuRawData/nanopore/fast5/macJie/20180925_2336_A188WGS092518a" >&2
	echo "	-o: path for outputs, required" >&2
	echo "	    example: /bulk/liu3zhen/LiuRawData/nanopore/fastq/macJie" >&2
	echo "	-c: flowcell; default=FLO-MIN106" >&2
	echo "	-k: kit; default=SQK-LSK109" >&2
	echo "	-f: outfmt; default=fastq" >&2
	echo "	-h: usage information and quit" >&2
	
}

# parameters
while getopts ":p:a:d:o:h" opt; do
	case $opt in
		p) pymodule=$OPTARG;;
		a) activate=$OPTARG;;
		d) datadir=$OPTARG;;
		o) outdir=$OPTARG;;
		c) flowcell=$OPTARG;;
		k) kit=$OPTARG;;
		f) outfmt=$OPTARG;;
		h) usage; exit;;
		\?) echo "Invalid options: -$OPTARG." >&2; exit;;
		:) echo "Option -$OPTARG requires an argument" >&2; exit;;
	esac
done

# check required parameters:
if [ -z $datadir ] || [ -z $outdir ]; then
	echo -e "${RED}ERROR:${NC}: Required parameters: -d; -o." >&2
	usage >&2;
	exit;
fi

# python module
if [ -z $pymodule ]; then
	pymodule=Python/3.6.4-foss-2018a
fi

# activate file
if [ -z $activate ]; then
	activate=/homes/liu3zhen/virtualenvs/python3.6.4/bin/activate
fi

# other parameters
#flowcell_db=
#kit_db=
#outfmt_db=

if [ -z $flowcell ]; then
	flowcell=FLO-MIN106
fi

if [ -z $kit ]; then
	kit=SQK-LSK109
fi

if [ -z $outfmt ]; then
	outfmt=fastq
fi

# load python and use virtual environment
module load $pymodule
source $activate

########################################################################
# setting - subject to change
#datadir=/bulk/liu3zhen/LiuRawData/nanopore/fast5/macJie/20180925_2336_A188WGS092518a
#outdir=/bulk/liu3zhen/LiuRawData/nanopore/fastq/macJie/
nthreads=$SLURM_CPUS_ON_NODE  # need to be consistent with SBATCH parameters
mem_per_thread=$SLURM_MEM_PER_CPU
########################################################################


# base calling with albacore
outname=$(echo $datadir | sed 's/.*\///g')
echo $outname
outsubdir=$outdir/$outname
if [ -d $outsubdir ]; then
	echo "Output directory exists. Pls clean the directory"
	exit 0
fi

# input data
if [ -d $datadir"/fast5" ]; then
	fast5dir=$datadir"/fast5"
else
	echo "${RED}ERROR:${NC}no fast5 directory exist!"
	exit 1;
fi

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
echo "output_directory="$outsubdir >>$logfile
echo "number of CPU="$nthreads >>$logfile
echo "mem per CPU="$mem_per_thread "M" >>$logfile

# basecalling
echo "basecalling started @" >>$logfile
date >> $logfile

fast5subdir=$(ls $fast5dir/* -d -1)
for fsd in $fast5subdir; do
	subdir=$(ls $fsd/* -d -1)
	fast5count=`ls -1 $fsd/*fast5 2>/dev/null | wc -l`
	if [ $fast5count != 0 ]; then
		echo "Processing fast5 in "$fsd >>$logfile
		read_fast5_basecaller.py --flowcell $flowcell --kit $kit --output_format $outfmt --input $fsd --save_path $outsubdir --worker_threads $nthreads
	else
		for fssd in $subdir; do
			echo "Processing fast5 in "$fssd >>$logfile
			read_fast5_basecaller.py --flowcell $flowcell --kit $kit --output_format $outfmt --input $fssd --save_path $outsubdir --worker_threads $nthreads
		done
	fi
done

echo "basecalling finished @" >>$logfile
date >> $logfile
# deactivate virtualenv
deactivate

