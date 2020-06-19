## GO enrichment analysis guide
###Input data
**de** dataframe containing genes, counts, adjusted p-values (padj)  
**godb** two-column dataframe (Gene and GO)  

### Data preparation
```
# add a column to state significance
fdr.cutoff <- 0.05
de$sig <- "no"
de$sig[de$padj < fdr.cutoff] <- "yes"

# count columns
head(datacols)
```

###GO enrichment
```
go <- goseq.auto(data = de,
                 godb = godb,
                 geneheader = "Gene",
                 sigcolname = "sig",
                 nsampling = 10000,
                 rawdatacol = datacols,
                 log2colname = NULL,
                 up.down = c("up", "down"),
                 pvalcutoff = 0.01,
                 minGene = 2,
                 outsave = T,
                 outpath = ".")
```

###GO plotting
```
goplot(go.out = go, main.space = 0.5, order.by = "pvals",
       term.space = 12, pval.cutoff = 0.01, xlim = c(0, 300))
```

