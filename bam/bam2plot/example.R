### example 2:
source("~/pipelines/bam2plot/bam2regionPlot.R")
bam2regionPlot(bamlist.file = "/data1/home/liu3zhen/CMN/RNA-Seq/visualization/batch1.bam.list.txt", check.bamlist = F,
               labels = c("R3CK", "R3CMN", "R4CK", "R4CMN", "S1CK", "S1CMN", "S4CK", "S4CMN"),
               chr = "chr1", from = 196215972, to = 196221349, rc = "rpm", cex.axis = 0.6, cex.main = 1, cex.lab = 0.9)
               
, labels = c("A", "B"),
               cols = c("orange", "blue"), rc = "rpm", cex.axis = 0.6, cex.main = 1, cex.lab = 0.9)
