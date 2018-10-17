### bam2regionPlot.R
The R script uses BAM files alongside their indexed files as input data and plot read distribution of each BAM data on a specified region. 

```
source("bam2regionPlot.R")
bamlist.file <- "https://raw.githubusercontent.com/liu3zhenlab/bio_scripts/master/bam/bam2plot/bamlist.txt"
bam2regionPlot(bamlist.file = bamlist.file, check.bamlist = F,
               labels = c("A", "B"),
               chr = "1", from = 196215972, to = 196221349, rc = "rpm",
               cex.axis = 0.6, cex.main = 1, cex.lab = 0.9)     
```
