# analysis for a single treatment RNA-seq data:
DESeq2.single.trt <- function (input.matrix, comparison, geneID=NULL,
                              group1.col=NULL, group2.col=NULL,
                              min.positive.samples=1, min.mean.reads=1,
                              fdr=0.05, logpath=".", logfile="default.log.md",
                              cooksCutoff=F, independentFiltering=T) {
  # Use the package of DESeq
  myversion <- "v0.01 11/17/2013 Sanzhen Liu"
  library(DESeq2)
  envinfo <- sessionInfo()
  platform <- envinfo $R.version$platform
  rversion <- envinfo $R.version$version.string
  deseq <- envinfo$otherPkgs$DESeq$Package
  deseq.version <- envinfo$otherPkgs$DESeq$Version
  
  logfile <- paste(logpath, "/", logfile, sep="")
  ### log output:
  cat(comparison[2], " vs. ", comparison[1], "\n", file=logfile)
  cat("=========================\n",
      "Running environment and package version\n",
      "-------------------------\n",
      "Platform =", platform, "  \n",
      rversion, "  \n",
      deseq, " version =", deseq.version, "  \n",
      "DESeq2.single.trt version=", myversion, "  \n", sep="",
      file=logfile, append=T)
  
  cat("Parameters\n",
      "-------------------------\n",
      "min.positive.samples = ", min.positive.samples, " *filter parameter before DE test*  \n",
      "min.mean.reads = ", min.mean.reads,  " *filter parameter before DE test*  \n",
      "cooksCutoff = ", cooksCutoff, " *DESeq filter to identify genes with outliers*  \n",
      "independentFiltering = ", independentFiltering, " *DESeq filter to
        identify genes that are unlikely to be DE*  \n",
      "FDR = ", fdr,  "  \n",
      "log output file = ", logfile, "  \n",
      sep="", file=logfile, append=T)
  
  # input.matrix:   see the example below, row names are gene IDs 
  #                 the input matrix should have the header each of 
  #                 which matches one of element of the comparison
  # comparison:     a vector of comparison information, e.g., c("w","m"), 
  #                 if group1.col and group2.col are not specified, these columns
  #                 will be automatically determined by "comparison". In this
  #                 case, the column names should contain the features specified
  #                 in the comparison
  # fdr:            false discovery rate
  # min.mean.reads: the minimum average reads required across all samples
  # min.positive.samples:  minimum number of samples with positive read counts
  # logfile:        log output file  
  
  # treatment: a vector of treatment information
  total.genes <- nrow(input.matrix)
  group1.col <- grep(comparison[1], colnames(input.matrix))
  group2.col <- grep(comparison[2], colnames(input.matrix))
  repnum1 <- length(group1.col)
  repnum2 <- length(group2.col)
  treatment <- c(rep("A", repnum1), rep("B", repnum2))
  in.data <- input.matrix[, c(group1.col, group2.col)]
  if (is.null(geneID)) {
    geneID <- rownames(input.matrix)
    print("Here are some examples of gene IDs:")
    print(head(geneID))
  }
  # filter low expressed genes:
  count.positive <- function (x) { sum(x>0, na.rm=T) }
  actual.positive.samples <- apply(in.data, 1, count.positive)
  filters <- (actual.positive.samples >= min.positive.samples &
             rowMeans(in.data) >= min.mean.reads)
  filter1 <- sum(!filters)
  in.data <- in.data[filters, ] # filtering
  geneID <- geneID[filters]
  
  # experimental design:
  in.data <- as.matrix(in.data)
  sample.info <- data.frame(row.names=colnames(in.data), trt=treatment)
  dds <- DESeqDataSetFromMatrix(countData=in.data, colData=sample.info, formula(~trt))
  dds <- DESeq(dds, "Wald")
  
  # DE:
  res <- results(dds, cooksCutoff=cooksCutoff,
                 independentFiltering=independentFiltering)

  res$GeneID <- geneID
  normalized.group1.rc.mean <- rowMeans(counts(dds, normalized=TRUE)[, 1:repnum1])
  normalized.group1.rc.mean <- round(normalized.group1.rc.mean, 1)
  normalized.group2.rc.mean <- rowMeans(counts(dds, normalized=TRUE)[, (repnum1+1):repnum2])
  normalized.group2.rc.mean <- round(normalized.group2.rc.mean, 1)
  res <- res[,c("GeneID", "log2FoldChange", "pvalue", "padj")]
  res$Group1mean <- normalized.group1.rc.mean
  res$Group2mean <- normalized.group2.rc.mean
  cp <- paste(comparison[2],"_",comparison[1],".",sep="")
  
  colnames(res) <- c("GeneID",
                     paste(cp,"log2FC",sep=""),
                     paste(cp,"pval",sep=""),
                     paste(cp,"qval",sep=""),
                     paste(comparison[1], "mean", sep="."),
                     paste(comparison[2], "mean", sep="."))
  
  out <- res
  filter2 <- sum(is.na(out[, paste(cp,"qval",sep="")]))
  out <- out[!is.na(out[, paste(cp,"qval",sep="")]), ]  ### remove qval=NA
  
  ### add sig column:
  out[, paste(cp,"sig",sep="")] <- "no"
  #sig.data <- out[, paste(cp,"qval",sep="")] <= fdr.cutoff
  out[out[, paste(cp,"qval",sep="")] <= fdr, paste(cp,"sig",sep="")] <- "yes"
  
  remain.genes <- nrow(out)
  
  cat("Differential expression results\n",
      "-------------------------\n",
      "Total genes = ", total.genes, "  \n",
      "Filtered by min.mean.reads and min.positive.samples = ", filter1, "  \n",
      "Filtered by DESeq = ", filter2, "  \n",
      "Remained genes in DE table = ", remain.genes, "  \n",
      sep="", file=logfile, append=T)
  fdrs <- c(0.05, 0.1, 0.15, 0.2, 0.25, 0.3)
  
  for (each.fdr in fdrs) {
    den <- sum(res[,paste(cp,"qval",sep="")] < each.fdr, na.rm=T) ## DE numbers
    if (each.fdr==fdr) {
      cat("**DE = ", den, " ,FDR = ", each.fdr, " (recommended)**  \n",
          sep="", file=logfile, append=T) 
    } else {
      cat("DE = ", den, " ,FDR = ", each.fdr, "  \n", sep="", file=logfile, append=T)
    }
  }
  
  return(out)
}

