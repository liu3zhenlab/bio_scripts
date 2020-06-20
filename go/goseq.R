goseq.auto <- function(data, godb, geneheader="GeneID", sigcolname="auto",
       nsampling=10000, rawdatacol, log2colname=NULL, up.down=c("up", "down"),
       pvalcutoff=0.05, minGene=1, outsave=T, prefix=NULL, outpath=".") { 
  # data: differential expression table
  # sigcolname: the column name of significant label column
  # rawdatacol: the raw read counts column for each sample
  # godb: required GO database, genes (column 1) + GO (column 2)
  # minGene: minimum "sig" genes in a GO
  # outpath: the path to output the result
  library(goseq)
  header <- colnames(data)
  print(outpath)
  if (sigcolname=="auto") {
    sigcolname = header[grep("sig",header)]
  }
  two.groups <- strsplit(gsub("_sig","",sigcolname), "[-:]")[[1]]
  print (two.groups)
  
  # data
  data <- data[!is.na(data[, sigcolname]),] # rm some un-informative data
  assayed.genes <- data[, geneheader]
  if (sum(up.down %in% c("up","down"))==2) {
    de.genes <- data[data[, sigcolname]=="yes", geneheader]
  } else {
    if (is.null(log2colname)) {
      log2colname <- gsub("_sig", "_log2FC", sigcolname) # assume this the a standard output
    }
    if (sum(up.down == "up")==1) {
      de.genes <- data[data[, sigcolname]=="yes" & data[, log2colname]>0, geneheader]
    } else {
      if (sum(up.down == "down")==1) {
        de.genes <- data[data[, sigcolname]=="yes" & data[, log2colname]<0, geneheader]
      } else {
        stop("the parameter up.down must equal to either up or down") 
      }
    }
  }
  up.down.note <- paste(up.down, collapse="_")
  #if (length(two.groups)>=2) {
  #  up.down.note <- paste(up.down.note, two.groups[1], "vs.", two.groups[2])
  #} else {
  #  up.down.note <- paste(up.down.note, two.groups)
  #}
  gene.vector = as.integer(assayed.genes %in% de.genes)
  names(gene.vector) = assayed.genes
  print(length(gene.vector))
  countbias <- rowSums(data[,rawdatacol])
  pwf.counts <- nullp(gene.vector, bias.data=countbias)
  # "Sampling" uses random sampling to approximate the true distribution
  # and uses it to calculate the p-values for over (and under) representation of categories.
  go <- goseq(pwf.counts, id=assayed.genes, gene2cat=godb, method="Sampling",repcnt = nsampling)
  print(head(go))
  go <- go[,c("category","over_represented_pvalue", "numDEInCat", "numInCat")]
  colnames(go) <- c("GO","pvalue", "numDEInGO", "numInGO")
  go$qvalue <- p.adjust(go$pvalue, method="BH")
  go.sig <- go[go$pvalue <= pvalcutoff & go$numDEInGO >= minGene, ]
  go.sig <- data.frame(go.sig)
  sig.go.vector <- go.sig[, 1]

  sig.num <- nrow(go.sig)

  if (sig.num == 0) {
    go.sig <- paste("No significantly enriched GOs were identified in", up.down.note)
  } else {
    go.sig$Comparison <- up.down.note
    # to get Term and Definition for each significant GO:
    library(GO.db)
    .godb <- select(GO.db, keys=sig.go.vector, columns=c("TERM","DEFINITION"),
                    keytype="GOID")
    .godb <- data.frame(.godb)
    go.term <- NULL
    go.def <- NULL
    
    print("Below lists significant GO")
    print(go.sig$GO)

    for (eachgo in go.sig$GO) {
      if (sum(.godb$GOID %in% eachgo) > 0) {
        go.term <- c(go.term, .godb[.godb$GOID == eachgo, "TERM"])
        go.def <- c(go.def, .godb[.godb$GOID == eachgo, "DEFINITION"])
      } else {
        go.term <- c(go.term, NA)
        go.def <- c(go.def, NA)
      }
    }
    go.sig$Term <- go.term
    go.sig$Def <- go.def
  }
  
  ### extract genes associated with significant GOs:
  go.sig.genes <- merge(go.sig, godb, by.x = "GO", by.y = colnames(godb)[2])
  go.sig.genes.data <- merge(go.sig.genes, data, by.x = colnames(godb)[1], by.y = geneheader)


  # output:
  outpath <- gsub("/$","",outpath)
  sigcolname2 <- gsub(":","-",sigcolname)
  if (is.null(prefix)) {
    prefix <- sigcolname2
  }
  up.down.label <- paste(up.down, collapse="_")
  go.outfile <- paste0(outpath,"/", prefix, ".", up.down.label, ".enriched.goseq.txt")
  gogene.outfile <- paste0(outpath,"/", prefix, ".", up.down.label, ".enriched.go.genes.txt")
  if (outsave) {
    if (sig.num == 0) {
      write.table(go.sig, go.outfile, row.names=F, col.names=F, quote = F, sep="\t")
    } else {
	  write.table(go.sig, go.outfile, row.names=F, quote = F, sep="\t")
      write.table(go.sig.genes.data, gogene.outfile, row.names=F, quote = F, sep="\t")
	}
  }
  # output
  invisible(go.sig)
}

