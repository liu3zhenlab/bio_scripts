
### fqlen2hist.R
An R script to plot the distribution (histogram) of read lengths.
```
perlscript <- "https://raw.githubusercontent.com/liu3zhenlab/bio_scripts/master/fastq/fastq2readlength.pl"
fqlen2hist(perlscript = perlscript,
           path = "<directory_containing_fastq>",
           feature = ".fastq",
           nbin = 30,
           title = "xxx")
```
