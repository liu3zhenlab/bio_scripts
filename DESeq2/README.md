### DESeq2.single.trt.R
R script to perform a single-factor comparison to identify differential expression (DE)

#### Fisrt, source the module
```
source("https://raw.githubusercontent.com/liu3zhenlab/bio_scripts/master/DESeq2/DESeq2.single.trt.R")
```

#### Second, generate an example data under null hypothesis
```
indata <- data.frame(Gene=paste("g", 1:5000, sep=""),
	Group1_rep1=rpois(n=5000, lambda=50),
	Group1_rep2=rpois(n=5000, lambda=50),
	Group1_rep3=rpois(n=5000, lambda=50),
	Group1_rep1=rpois(n=5000, lambda=50),
	Group2_rep1=rpois(n=5000, lambda=50),
	Group2_rep2=rpois(n=5000, lambda=50),
	Group2_rep3=rpois(n=5000, lambda=50))
```

#### Third, perform pair-wise comparison
```
comparison <- c("Group1", "Group2")
group1 <- comparison[1]
group2 <- comparison[2]

input <- indata[,c(grep(group1, colnames(indata)),
                  grep(group2, colnames(indata)))]
rownames(input) <- indata[, 1]

# DE:
DE.out <- DESeq2.single.trt(input.matrix=input, comparison=comparison,
                            geneID=rownames(input), fdr=0.05,
                            logpath=".", logfile="log.log")
```
