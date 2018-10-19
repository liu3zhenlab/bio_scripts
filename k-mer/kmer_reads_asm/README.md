### kmer_reads_asm
A pipeline to search reads harboring k-mers for de novo assembly.

#### required data files:
1. kmer_table: two columns with 1st column of k-mer names and 2nd column of k-mer sequences
2. fastq_files: at least one fastq file is needed; multple fastq can be input.
```
perl kmer2fqreads.pl <kmer_table> <fastq_files>
```
