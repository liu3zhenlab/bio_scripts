GATK_pipelines
==============
This repository is an simple example for how to use GATK to discover SNP and INDELs. It is for the tutorial purpose. The parameters are not optimized.

Two shell scripts were used in the analysis: snp.sh and variantSelect.sh. In each of the scripts, you need to change various things in the PART1. After the modification, run:

sh snp.sh ### discover both SNPs and INDELs

sh variantSelect.sh ### select confident SNPs


