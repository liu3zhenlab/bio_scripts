############################################################
## qRT-PCR analysis using the 2^-ΔΔCt method
## NA values are replaced with a random value from 36 to 40
############################################################
library(dplyr)
library(tidyr)
library(ggplot2)
library(multcompView)

##################################################################
# User parameters
##################################################################
# experiment
exp_id <- NULL

# control name
control <- "control"

# housekeeping gene
hk <- "ubq"

# gene of interest
goi <- "ole"

# optional order/filter of treatment groups
plot_groups <- NULL
plot_cols <- NULL  # bar color, default=gray80
#c("bisque", "palegreen", "lightskyblue1", "seashell1", "ivory", "snow1")

# input data
datafile <- "qPCR.data"

# data outputs
outdata <- "qPCR.individual.csv"
summaryout <- "qPCR.summary.csv"

# plot output
pwidth <- 4
pheight <- 4
outpdf <- "qPCR.barplot.pdf"

############################################################
## Read data
############################################################
df <- read.delim(datafile, stringsAsFactors=F)

## check data
stopifnot(sum(df$Treatment %in% control)>0) # control input

stopifnot(sum(df$Gene %in% goi)>0) # gene of interest
stopifnot(sum(df$Gene %in% hk)>0) # housekeeping gene

if (!is.null(plot_groups)) { # check plot_groups input
  ngroups <- sum(plot_groups %in% df$Treatment)
  stopifnot(ngroups == length(plot_groups))
}

## subset if needed
if (!is.null(exp_id)) {
  df <- df[df$Experiment == exp_id, ]
}

if (!is.null(plot_groups)) { 
  df <- df[df$Treatment %in% plot_groups, ]
}

df <- df[df$Gene %in% c(hk, goi), ]

############################################################
## Clean data
############################################################
df$Sample    <- trimws(df$Sample)
df$Treatment <- trimws(df$Treatment)
df$Gene      <- trimws(df$Gene)

# Convert Cq to numeric
df$Cq <- as.numeric(df$Cq)
summary(df$Cq)
df[df$Treatment==control, ]

# Replace NA Ct values with 36-40
df$Cq[is.na(df$Cq)] <- sample(36:40, sum(is.na(df$Cq)), replace=T) # NA to random from 36 to 40

############################################################
## Average technical replicates
############################################################
mean_ct <- df %>%
  group_by(Experiment, Sample, Treatment, Incubation, Gene) %>%
  summarise(
    mean_Cq = mean(Cq),
    sd_Cq   = sd(Cq),
    n       = n(),
    .groups = "drop"
  )
# drop: remove group information; not factor anymore

mean_ct

############################################################
## Convert to wide format
############################################################
wide_ct <- mean_ct %>%
  select(Experiment,
         Sample,
         Treatment,
         Incubation,
         Gene,
         mean_Cq) %>%
  pivot_wider(
    names_from = Gene,
    values_from = mean_Cq
  )

wide_ct

############################################################
## Calculate ΔCt
############################################################
## ΔCt = Target - Reference(ubq)
wide_ct$dCt <- wide_ct[, goi][[1]] - wide_ct[, hk][[1]] # dCt value

wide_ct

############################################################
## Calculate calibrator (TVEV)
############################################################
#calibrator <- wide_ct %>%
#  filter(Treatment == control) %>%
#  summarise(
#    cal_value = mean(dCt)
#  )
control_dCt <- wide_ct[wide_ct$Treatment == control, "dCt"][[1]]
calibrator <- mean(control_dCt)

############################################################
## Calculate ΔΔCt and fold change
############################################################
wide_ct <- wide_ct %>%
  mutate(
    ddCt = dCt - calibrator,
    FC   = 2^(-ddCt),
  )

wide_ct

############################################################
## Summary statistics
############################################################
summary_fc <- wide_ct %>%
  group_by(Treatment) %>%
  summarise(
    mean_FC = mean(FC, na.rm = TRUE),
    sd_FC   = sd(FC, na.rm = TRUE),
    .groups = "drop"
  )

print(summary_fc)

### obtain plot_groups information
if (is.null(plot_groups)) {
  plot_groups <- summary_fc$Treatment
}
############################################################
## Save results
############################################################
write.csv(wide_ct, outdata, row.names=F)
write.csv(summary_fc, summaryout, row.names=F)

############################################################
## Statistical tests on ΔCt
############################################################
stat_data <- wide_ct %>%
  filter(!is.na(dCt))

anova_out <- aov(dCt ~ Treatment,
                 data = stat_data)

summary(anova_out)

tk <- TukeyHSD(anova_out)

# extract adjusted p-values
pvals <- tk$Treatment[, "p adj"]

# generate letters
group_letters <- multcompLetters(pvals)$Letters
group_letters <- group_letters[plot_groups]

##################################################################
# preparation for plotting
##################################################################
exp.mean <- tapply(
  wide_ct$FC,
  wide_ct$Treatment,
  mean,
  na.rm = TRUE
)

exp.sd <- tapply(
  wide_ct$FC,
  wide_ct$Treatment,
  sd,
  na.rm = TRUE
)

exp.mean <- exp.mean[plot_groups]
exp.sd <- exp.sd[plot_groups]


##################################################################
# Plot
##################################################################

pdf(outpdf, width = pwidth, height = pheight)
par(mar=c(3, 4, 3, 0.1))

plot.ymax <- max(wide_ct$FC) * 1.05

main.text <- bquote(
  italic(.(as.name(goi))) ~ expression
)

### to simplify group names
group_names <- sub(paste0(goi, "_"), "", plot_groups)

if (is.null(plot_cols)) {
	plot_cols <- "gray80"
}

barcenters <- barplot(
  exp.mean,
  names.arg = group_names,
  ylab = "Fold change",
  las = 1,
  cex.names = 0.8,
  ylim = c(0, plot.ymax),
  main = main.text,
  col = plot_cols
)

## Error bars
arrows(
  barcenters,
  exp.mean - exp.sd,
  barcenters,
  exp.mean + exp.sd,
  angle = 90,
  length = 0.1,
  code = 3
)

##################################################################
# Individual points and Tukey letters
##################################################################
plotexp_y <- wide_ct$FC
plotexp_x <- factor(
  wide_ct$Treatment,
  levels = plot_groups
)

for (i in seq_along(plot_groups)) { # similar to 1:nrow(plot_groups)
  y <- plotexp_y[plotexp_x == plot_groups[i]]
  
  x <- jitter(
    rep(barcenters[i], length(y)),
    amount = 0.08
  )
  
  points(
    x,
    y,
    pch = 19,
    cex = 1.2,
    col = "gray30",
    xpd = TRUE
  )
  
  text(
    barcenters[i],
    max(y),
    labels = group_letters[i],
    pos = 3,
    xpd = TRUE
  )
}

dev.off()

