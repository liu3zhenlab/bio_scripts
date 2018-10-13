#setwd("/home/liu3zhen/pipelines/bam2plot")
### input data
#bamlist <- read.delim("./data/bam.list", header = F, stringsAsFactors = F)
# bamlist.file <- "./data/bam.list"
# chr <- "U00096"
# from <- 10000
# to <- 15000
# labels <- c("B", "M")
# cols <- c("blue", "red")
# rc <- "rpm"
bam2regionPlot <- function (bamlist.file, bamreadnum.file, check.bamlist = F, chr, from, to,
                            labels, cols, rc = "rpm", rc.label.cex = 1, rpmg.max = NULL, sample.label.cex = 0.8,
                            main.label = NULL, las.value = 1, outsave = F, outpath = ".", outfile, ...) {
# bamlist.file: a file lists BAM files, one BAM file per line; if the second column, separated by TAB, was filled, that must be the read number of the bam file
# check.bamlist: logical, for the purpose to check the BAM file list but do anything else
# chr: target sequence name
# from: the start chr position to be plotted
# to: the end chr position to be plotted
# labels: labeling 
# cols
# rc: rpk, reads per thousand; rpm, reads per million; or rpg, reads per billion
# rpmg.max: if all rpm/rpg values exceed the rpmg.max, the site will not be plotted
# sample.label.cex: cex for sample labeling, default = 0.8
# outsave: logical, TRUE to indicate if the plot will be saved in a file
# outpath: output directory
# outfile: output filename
  
### before run this module, check the parameters:
  if (missing(bamlist.file)) {
    stop("The required file lists BAM files.\nNOTE: One BAM file per line and no header.")
  } else {
    bamlist <- read.delim(bamlist.file, header = F, stringsAsFactors = F)
  }
  
  if (check.bamlist) {
    cat("There are", nrow(bamlist), "BAM files\n")
    cat("---------------------------------------\n")
    cat(bamlist[, 1], sep = "\n")
    cat("---------------------------------------\n")
    return("Only check BAM file list. Please setup labels and cols based on the BAM list")
  }

  if (missing(chr) | missing(from) | missing(to) | missing(labels) | missing(cols)) {
    stop("check these REQUIRED parameters: chr (char), from (int), to (int), labels (vector), cols (vector)")
  }
  
  if (!missing(labels) & length(labels) != length(bamlist[, 1])) {
    stop("labels are the names used for labeling each track. The label number should equal to the number of BAM file\n
         If a label name is to be used for multiple BAM files, just repeat this name. The order should match to the BAM file list")
  }
  
  if (!missing(cols) & length(cols) != length(bamlist[, 1])) {
    stop("cols is the list of colors. The color number should match the BAM file")
  }
  
### step 1: determine library size
  flagstat2libsize <- function(flagstat, reads = c("read1", "read2")) {
  ### flagstat is the output from samtools flagstat
  ### output is the total number of SE reads
    reads <- paste(reads, collapse = "|")
    readstat <- flagstat[grep(reads, flagstat)]
    readstat <- gsub(" \\+.*", "", readstat)
    readstat <- as.numeric(readstat)
    sum(readstat)
	readstat <- sum(readstat)

	### if read1 and read2 show 0 counts, then examine 20959 + 0 in total
	if (readstat == 0) {
		readstat <- flagstat[grep("total", flagstat)]
		readstat <- gsub(" \\+.*", "", readstat)
	}
	readstat <- as.numeric(readstat)
	readstat
  }
  
  libsize <- NULL
  if (ncol(bamlist) >= 2) {
    libsize <- bamlist[, 2]
  } else {
    for (bam in bamlist[, 1]) {
      fs <- system(paste("samtools flagstat", bam), intern = T)
      libsize <- c(libsize, flagstat2libsize(fs))
	  print(libsize)

    }
  }
  names(libsize) <- bamlist[, 1]
  cat(paste(names(libsize), libsize), sep = "\n")

### step 2: counts:
  bamname.file <- tempfile(".bamname", fileext = ".txt")
  write.table(bamlist[, 1], bamname.file, quote = F, row.names = F, col.names = F, sep = "\t")
  counts.tmp <- tempfile(".counts", fileext = ".txt")  
  system(paste0("samtools depth -r ", chr, ":", from, "-", to, " -f ", bamname.file, " > ", counts.tmp))
  counts <- read.delim(counts.tmp, header = F, stringsAsFactors = F)
  unlink(counts.tmp)
  head(counts)
  colnames(counts) <- c("Chr", "Pos", bamlist[, 1])
    
  counts2 <- counts[, 1:2]

### step 3: reorganize data:
  libsize2 <- NULL
  recols <- NULL
  for (group in unique(labels)) {
    samplelist <- bamlist[labels %in% group, 1]
    counts2[, group] <- apply(counts[samplelist], 1, sum)
    libsize2 <- c(libsize2, sum(libsize[samplelist]))
    recols <- c(recols, cols[labels %in% group][1])
  }
  
  
### step 4: determine plotting parameters:
  if (rc == "rpm") {
    adjust.rc <- 1000000
  } else {
    if (rc == "rpg") {
      adjust.rc <- 1000000000
    } else {
		if (rc == "rpk") {
			adjust.rc <- 1000
		} else {
			stop("ERROR: Only rpm or rpg can be set up for normalization")
		}
	}
  }
  
  # convert counts to rpm or rpg or rpk:
  rpm <- counts2
  ymax <- 0 

  rpm.qualified <- rep(FALSE, nrow(counts))
  
  ### plot every data sets
  for (i in 3:ncol(counts2)) {
    rpm[, i] <- counts2[, i] / libsize2[i - 2] * adjust.rc
    if (!is.null(rpmg.max)) {
		rpm.qualified <- rpm.qualified | (rpm[, i] <= rpmg.max)
	}
	ymax <- max(ymax, rpm[, i])
  }
  
  if (!is.null(rpmg.max)) {
  	rpm <- rpm[rpm.qualified, ]
  	ymax <- rpmg.max * 1.05
  }

  ngroups <- ncol(counts2) - 2
  width <- 5 # inch
  height <- width * length(labels) / 3
  gap <- ymax / 5
  xlabel <- paste("Position on", chr)
  pos_range <- c(from, to)

  yrange <- c(0, (ymax + gap) * ngroups - gap)
  if (is.null(main.label)) {
    main.label <- paste0(chr, ":", from, "-", to)
  }
### step 5: plotting
  if (outsave) {
    outfile <- paste0(outpath, "/", outfile)
    png(outfile, width = width, height = height, units = "in", pointsize = 4, res = 1200)
  }

  par(mar = c(4.5, 4.5, 3.5, 1), ...)
  plot(NULL, NULL, xlim = pos_range, ylim = yrange, xlab = xlabel, ylab = toupper(rc),
       main = main.label, bty = "n", yaxt = "n")
  
  base <- 0
  for (i in 3:ncol(rpm)) {
    for (j in 1:nrow(rpm)) {
      lines(c(rpm[j, 2], rpm[j, 2]), c(base, base + rpm[j, i]), col = recols[i - 2])
    }
    
    ymax.int <- floor(ymax)
	if (ymax.int == 0) {
		ymax.int <- ymax
	}
    axis(2, at = c(base, base + ymax.int), labels = c(0, ymax.int), las = las.value, cex.axis = rc.label.cex)
    mtext(colnames(rpm)[i], side = 2, at = base + ymax/2, adj = 1.5, xpd = T,  padj = 0.5, cex = sample.label.cex, las = las.value)
    base <- base + ymax + gap
  }  
  
  if (outsave) { dev.off() }
}
