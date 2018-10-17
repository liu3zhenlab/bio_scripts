### bam2regionPlot.R
The R script uses BAM files alongside their indexed files as input data and plot read distribution of each BAM data on a specified region.

_An only input file_ specified when running the script is a flat text file containing the list of BAM file. Each row specifies a BAM file name in the first column, which includes the path. The second column to contain library size (the number of total reads) is optional. To add the second column save the time for the plotting script to skip the step of determining library size.

```
gitpath <- "https://raw.githubusercontent.com/liu3zhenlab/bio_scripts/master/bam/bam2plot/"
source(paste0(gitpath, "bam2regionPlot.R"))
bamlist.file <- paste0(gitpath, "bamlist.txt")
bam2regionPlot(bamlist.file = bamlist.file, check.bamlist = F,
               labels = c("DH10B", "MG1655"),
               chr = "U00096", from = 100, to = 1000, rc = "rpm",
               cols = c("orange", "blue"),
               cex.axis = 0.6, cex.main = 1, cex.lab = 0.9)     
```
