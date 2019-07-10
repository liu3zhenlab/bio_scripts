#!/bin/sh
# the script is to generate a new sequence with replacements with variants in the vcf file

# input
oldseq=old.seq
vcf=variants.vcf
newseq=new.fasta
log=vcf2fas.log

# run
gatk FastaAlternateReferenceMaker -R $oldseq -V $vcf -O $newseq &>$log
