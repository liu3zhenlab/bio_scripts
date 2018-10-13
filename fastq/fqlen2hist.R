.n50 <- function(num) {
# calculate N50
# by Sanzhen Liu
  num <- sort(num, decreasing =  T)
  gt.half.total <- which(cumsum(num) > sum(num) / 2)
  num[gt.half.total[1]]
}

.num.1000sep <- function (x) {
# convert number to 1000 separated format
# by Sanzhen Liu
  x2 <- strsplit(as.character(x),"\\.")[[1]]
  comma.num <- ceiling(nchar(x2[1])/3)-1
  y <- substr(x,1,nchar(x2[1])-comma.num*3)
  position <- nchar(y)+1
  if (comma.num>0) {
    for (i in 1:comma.num) {
      extract <- substr(x,position,position+2)
      y <- paste(y,",",extract,sep="")
      position <- position + 3
    }
  }
  if (length(x2)>1) {
    y <- paste(y,".",x2[2],sep="")
  }
  y
}

# main code
fqlen2hist <- function(perlscript = "/home/liu3zhen/scripts/fastq/fastq2readlength.pl",
                      path = ".",
                      feature = ".fastq",
                      nbin = 30,
                      title = "") {
  fqfiles <- dir(path, pattern = feature)
  arlen <- NULL

  # go through each data set
  for (efq in fqfiles) {
    fq <- paste0(path, efq)
    rlen <- system(paste("perl", perlscript, fq), intern = T)
    arlen <- c(arlen , rlen)
  }

  # summary statistics
  arlen <- as.numeric(arlen) / 1000
  rlmax <- round(max(arlen), 1)
  rln50 <- round(.n50(arlen), 1)
  rlmedian <- round(median(arlen), 1)
  rlsum <- round(sum(arlen))
  rlsum.gt5kb <- round(sum(arlen[arlen >= 5]))
  rlsum.gt10kb <- round(sum(arlen[arlen >= 10]))

  # histogram
  total.reads <- .num.1000sep(as.character(length(arlen)))
  histout <- hist(arlen, main = paste0(title, "\nN=", total.reads),
       xlab = "read length (kb)",
       ylab = "Number of reads",
       nclass = nbin)
  abline(v = c(rlmedian, rln50), col = c("blue", "red"))

  #add note
  xmax <- max(histout$mids)
  ymax<- max(histout$counts)
  linelen <- ymax / 10

  text.x <- xmax/3
  text(x = text.x, y = ymax - linelen * 2,
       labels =  paste0("median=", rlmedian, " kb"),
       col = "blue", pos = 4, cex = 1.2, lwd = 1.2)
  text(x = text.x, y = ymax - linelen * 3,
       labels =  paste0("N50=", rln50, " kb"),
       col = "orange", pos = 4, cex = 1.2, lwd = 1.2)
  text(x = text.x, y = ymax - linelen * 4,
       labels =  paste0("longest=", rlmax, " kb"),
       col = "purple", pos = 4, cex = 1.2, lwd = 1.2)
  text(x = text.x, y = ymax - linelen * 5,
       labels =  paste0("total(>5kb)=", .num.1000sep(as.character(rlsum.gt5kb)), " kb"),
       col = "brown", pos = 4, cex = 1.2, lwd = 1.2)
  text(x = text.x, y = ymax - linelen * 6,
       labels =  paste0("total(>10kb)=", .num.1000sep(as.character(rlsum.gt10kb)), " kb"),
       col = "dark green", pos = 4, cex = 1.2, lwd = 1.2)
  text(x = text.x, y = ymax - linelen * 7,
       labels =  paste0("total=", .num.1000sep(as.character(rlsum)), " kb"),
       col = "red", pos = 4, cex = 1.2, lwd = 1.2)
}


#pdf("A188WGS180925A-nanopore.readlen.pdf", width = 5, height = 4.5)
#fqlen2hist(path = "/data1/home/raw/A188WGS/Nanopore/A188WGS180925A/20180925_2336_A188_15KB/fastq/pass/", title = "A188WGS180925A-nanopore")
#dev.off()
