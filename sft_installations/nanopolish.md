## nanopolish
Installation of Nanopolish for error correction of draft assemblies with PacBio or nanopore data.
```
git clone --recursive https://github.com/jts/nanopolish.git
# --recursive is important for successful installation
cd nanopolish
make
```

#### example
Here is how I did on Beocat at K-State:

1. step 1: generate a file list of "sequencing_summary.txt", including full paths
```
ls /bulk/liu3zhen/LiuRawData/nanopore/guppy/*/*/sequencing_summary.txt -1 > ss_list
```

2. step 2: index reads
```
f5files_dir=/bulk/liu3zhen/LiuRawData/nanopore/fast5/
reads=A188WGS_Sep2Dec2019_min5kb_guppyPASS.fasta
seq_sum_file_list=ss_list
np_dir=/homes/liu3zhen/software/nanopolish/nanopolish_0.11.0
$np_dir/nanopolish index -d $f5files_dir -f $seq_sum_file_list $reads
```

3. step3: polishing
```
seq=example.fas
reads=/bulk/liu3zhen/LiuRawData/nanopore/guppy/all_merge/A188WGS_Sep2Dec2019_min5kb_guppyPASS.fasta
bam=A188WGS_Sep2Dec2019_min5kb_guppyPASS.A188ONTasm01.bam
npPath=/homes/liu3zhen/software/nanopolish/nanopolish_0.11.0
# call variants
$npPath/nanopolish variants --consensus \
	-o out.vcf \
	-r $reads \
	-b $bam \
	-g $seq \
	-t 8

# change fasta based on vcf
$npPath/nanopolish vcf2fasta --skip-checks -g $seq out.vcf > polished.fas
```
Our test run on a ~800kb sequence takes ~16h to finish. The highest member usage was ~18Gb.
