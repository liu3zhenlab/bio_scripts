### kmer_reads_asm
A pipeline to search reads harboring k-mers for de novo assembly.

#### Prerequirement
1. seqtk
2. wgs assembler

#### step 1. find reads harboring k-mers - kmer2fqreads.pl
_required data files_
1. kmer_table: two columns with 1st column of k-mer names and 2nd column of k-mer sequences
2. fastq_files: at least one fastq file is needed; multple fastq can be input.
```
perl kmer2fqreads.pl <kmer_table> <fastq_files>
```
### step 2. extract reads sequences

kmer=$1
grep $kmer 1o.txt  | cut -f 2 > $kmer
seqtk subseq ../data/data_1.fq k1 > $kmer_reads_1.fq
seqtk subseq ../data/data_2.fq k1 > $kmer_reads_2.fq

### step 3.
fastqToCA -insertsize 300 150 -libraryname $library \
	-technology illumina-long -type sanger \
	-innie -mates $fq1,$fq2 -nonrandom > fq.frg
runCA -d . -p bacend fq.frg
