#' Function for go enrichment plotting
#' @param go.out  output file from GO enrichment analysis 
#' @param order.by  three options: pvals, num, enrich; no sorting by default)        
#' @param go.obs.num.col  column for number of genes observed for a GO ("numDEInGO")
#' @param go.exp.num.col  column for number of total genes for a GO ("numInGO")
#' @param bar.obs.color  color to plot number of genes observed ("cornflowerblue")
#' @param bar.exp.color  color (transparent) to plot number of total genes (rgb(0.9, 0.9, 0.9, 0.5))
#' @param term.col  the colname or column number for GO term information ("Term")
#' @param term.cex  cex for term text (0.75)
#' @param term.space  space for terms (18)
#' @param pval.col  column for pvalues ("pvalue")
#' @param pval.cutoff  pvalue cutoff for the plotting (0.01)
#' @param add.pval  logic value to whether to add pvalues (TRUE)
#' @param pval.cex   cex for pvalue text (0.8)
#' @param enrich.col  column for enrichments (NULL)
#' @param enrich.cutoff  minimum cutoff for enrichments (1.5)
#' @param min.gene.counts  minimum number of genes observed (2)
#' @param axis.cex  cex for x-axis (0.8)
#' @param tick.num  number of ticks at x-axis (10)
#' @param xlab.cex  cex for xlab (0.8)
#' @param main.space  space for main (1)
#' @param oursave  logic value to indicate whether to save the output plot (FALSE)
#' @param outfile  the output plot file name, including the path if needed
#' @param pdf.width  width of the plot (6)
#' @param pdf.height  height of the plot (6)
#' @return output a barplot for enriched GOs
#' @author Sanzhen Liu (liu3zhen@gmail.com)
goplot <- function(go.out,
                   order.by = c("pvals", "num", "enrich"),
				   go.obs.num.col = "numDEInGO",
				   go.exp.num.col = "numInGO",
				   bar.obs.color = "cornflowerblue",
                   bar.exp.color = rgb(0.9, 0.9, 0.9, 0.5),
                   term.col = "Term", term.cex = 0.75, term.space = 18,
				   pval.col = "pvalue", pval.cutoff = 0.01,
				   add.pval = TRUE, pval.cex = 0.8,
				   enrich.col = NULL, enrich.cutoff = 1.5,
				   min.gene.counts = 2, axis.cex = 0.8,
				   tick.num = 10, xlab.cex = 0.8,
				   main.space = 1,
				   outsave = F, outfile,
				   pdf.width = 6, pdf.height = 6, ...) {
### 2/10/2016
### updated 5/8/2019
### updated 6/19/2020
  if (outsave) {
    pdf(outfile, width=pdf.width, height=pdf.height)
  }
  
  # pval filter
  if (!is.null(pval.col)) {
    sigresult <- go.out[go.out[, pval.col] < pval.cutoff, ]
  } else {
  	sigresult <- go.out
  }

  # enrich filter
  if (!is.null(enrich.col)) {
  	sigresult <- sigresult[sigresult[, enrich.col] > enrich.cutoff, ]
  }

  # gene number filter
  if (!is.null(min.gene.counts)) {
  	sigresult <- sigresult[sigresult[, go.obs.num.col] >= min.gene.counts, ]
  }

  # plotting
  if (nrow(sigresult) > 0) {
    if (outsave) {
      pdf(outfile, width=pdf.width, height=pdf.height)
	}
    
	# order GO terms
	if (length(order.by) == 1) {
		if (order.by == "pvals" & !is.null(pval.col)) {
			sigresult <- sigresult[order(sigresult[, pval.col], decreasing = T), ]
		} else {
			if (order.by == "enrich" & !is.null(enrich.col)) {
				sigresult <- sigresult[order(sigresult[, enrich.col]), ] 
			} else {
				if (order.by == "num" & !is.null(go.obs.num.col)) {
					sigresult <- sigresult[order(sigresult[, go.obs.num.col]), ]
				} else {
					cat("Only three choices for order.by: pvals, num, enrich")
				}
			}
		}
	}

    # plot
    plotdata <- sigresult[, c(go.obs.num.col, go.exp.num.col, pval.col)]
    plotnames <- as.character(sigresult[, term.col])
	plotpval <- formatC(plotdata[, 3], format = "e", digits = 0)

    plotdata <- as.matrix(plotdata[!is.na(plotnames), ])  ### remove NA
    plotnames <- plotnames[!is.na(plotnames)]

	par(mar=c(3, term.space, main.space , 2))
    # obs
	barpos <- barplot(plotdata[, 1], names.arg = "", horiz=T, col=bar.obs.color,
            axes=F, xlab="", ...)
    # exp
	barplot(plotdata[, 2], names.arg=plotnames, horiz=T, las=2, col=bar.exp.color,
            axes=F, cex.names=term.cex, xlab="", add = T)
 	
	if (add.pval) {
 		text(plotdata[, 2], barpos, plotpval, pos=4, cex=pval.cex) 
    }
	abline(v=0)
	par(mgp = c(3, 0.5, 0))
	xmax <- ceiling(max(plotdata) / tick.num) * tick.num
	axis(side=1, at =seq(0, xmax, xmax / tick.num), cex.axis = axis.cex)
	mtext(text = "Number of genes", line = 1.5, side = 1, cex = xlab.cex)
    if (outsave) { dev.off() }
  }
}
