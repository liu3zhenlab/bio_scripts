
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
