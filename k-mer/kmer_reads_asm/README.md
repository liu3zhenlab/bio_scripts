### kmer_reads_asm
A pipeline to search reads harboring k-mers for de novo assembly.

#### Prerequirement
1. seqtk
2. wgs assembler

### input
```
kmer_table=../data/data_kmer.txt
infq1=../data/data_1.fq
infq2=../data/data_2.fq

### intermediate 
kmerid_reads=kmertable.tmp
```

#### step 1. find reads harboring k-mers - kmer2fqreads.pl
_required data files_
1. kmer_table: two columns with 1st column of k-mer names and 2nd column of k-mer sequences
2. fastq_files: at least one fastq file is needed; multple fastq can be input.
_Usage_: perl kmer2fqreads.pl <kmer_table> <fastq_files>
```
perl kmer2fqreads.pl $kmer_table $infq1 $infq2 >$kmerid_reads
```

### step 2. extract reads sequences
```
select_kmer_id=k1
outdir=$select_kmer_id"_output"
pe.reads.extraction -k $select_kmer_id -t $kmerid_reads -f $infq1 -s $infq2 -o $outdir
```

### step 3. assemble reads
```
pe2asm -f $outdir/k1_data_1.fq -s $outdir/k1_data_2.fq -o $outdir -n k1asm
```

