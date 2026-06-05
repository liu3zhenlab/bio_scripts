# qRT-PCR Analysis

This repository contains scripts for qRT-PCR data analysis using the 2^-ΔΔCt method.

## Input Data

The input qRT-PCR data should be provided as a tab-delimited text file or CSV file with the following columns:

| Column | Description |
|----------|-------------|
| Experiment | Experiment identifier |
| Sample | Biological sample name |
| Treatment | Treatment condition |
| Incubation | Incubation time or condition |
| Gene | Gene name |
| Cq | Quantification cycle (Cq) value |

### Example

| Experiment | Sample | Treatment | Incubation | Gene | Cq |
|------------|--------|-----------|------------|------|----|
| Exp1 | WT | Control | 0 h | ubq | 21.5 |
| Exp1 | WT | Control | 0 h | oleosin1 | 27.3 |
| Exp1 | OE | Heat | 24 h | ubq | 20.8 |
| Exp1 | OE | Heat | 24 h | oleosin1 | 24.6 |

## Analysis Workflow
1. Import qRT-PCR data.
2. Calculate mean Cq values for technical replicates.
3. Calculate ΔCt using the housekeeping gene.
4. Calculate ΔΔCt relative to the control sample.
5. Calculate fold change as 2^-ΔΔCt.
6. Perform statistical analysis and generate plots.

## Requirements
R packages:
dplyr
tidyr
multcompView 
