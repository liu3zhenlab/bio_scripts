### fastq.total.bases.sh
A Shell script to combine *seqtk* and awk to determine total basepairs, which contains two lines of codes.
```
fq=$1;
seqtk comp $fq | awk '{total += $2} END {print "Total bases:", total}'
```
To run that, just type
```
sh fastq.total.bases.sh <a fastq file>
```
### fastq2readlength.pl
A Perl script to calculate length (bp) of each read in input fastq files. A basepair number per read was output in a line in the output file.
```
perl fastq2readlength.pl *fastq
```
### fqlen2hist.R
An R script to plot the distribution (histogram) of read lengths.
```
fqlen2hist.r.file <- "https://raw.githubusercontent.com/liu3zhenlab/bio_scripts/master/fastq/fqlen2hist.R"
fq2len.perl.file <- "https://raw.githubusercontent.com/liu3zhenlab/bio_scripts/master/fastq/fastq2readlength.pl"
source(fqlen2hist.r.file)
fqlen2hist(perlscript = fq2len.perl.file,
           path = "<directory_containing_fastq>",
           feature = ".fastq",
           nbin = 30,
           title = "xxx")
```
### trimmomatic.PE.LT.sh
A script to trim adaptor and low-quality sequences for Illumina PE reads
