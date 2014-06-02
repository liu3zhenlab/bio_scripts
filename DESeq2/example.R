#############################################
### RNA-Seq DESeq2: single treatment analysis
### Kansas State University
### Sanzhen Liu
### date: 5/21/2014
#############################################

#############################################
### load modules
#############################################
source("DESeq2.single.trt.R")
#############################################

#############################################
### testing using diff parameters (DE)
#############################################
# generate data under null hypothesis:
indata <- data.frame(Gene=paste("g", 1:5000, sep=""),
	Group1_rep1=rpois(n=5000, lambda=50),
	Group1_rep2=rpois(n=5000, lambda=50),
	Group1_rep3=rpois(n=5000, lambda=50),
	Group1_rep1=rpois(n=5000, lambda=50),
	Group2_rep1=rpois(n=5000, lambda=50),
	Group2_rep2=rpois(n=5000, lambda=50),
	Group2_rep3=rpois(n=5000, lambda=50))

# pair-wise comparison:
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
#############################################

