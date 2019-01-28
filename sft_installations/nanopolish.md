## nanopolish
Installation of Nanopolish for error correction of draft assemblies with PacBio or nanopore data.
```
git clone --recursive https://github.com/jts/nanopolish.git
# --recursive is important for successful installation
cd nanopolish
make
```

#### example
Here is how I did on Beocat at K-State
o step 1: generate a file list of "sequencing_summary.txt", including full paths
```
ls /bulk/liu3zhen/LiuRawData/nanopore/guppy/*/*/sequencing_summary.txt -1 > ss_list
```

o step 2: index reads
```
f5files_dir=/bulk/liu3zhen/LiuRawData/nanopore/fast5/
reads=A188WGS_Sep2Dec2019_min5kb_guppyPASS.fasta
seq_sum_file_list=ss_list
np_dir=/homes/liu3zhen/software/nanopolish/nanopolish_0.11.0
$np_dir/nanopolish index -d $f5files_dir -f $seq_sum_file_list $reads
```

o step3: polishing

