### Tips for VCF operation

1. update VCF sequence dictionary with sequence names in a FASTA file using Picard
```
fasta=
seqdict=
vcf=
newvcf=

# produce sequence dictionary
java -jar picard.jar CreateSequenceDictionary R=$fasta O=$seqdict

# update sequence dictionary in the VCF file
java -jar picard.jar UpdateVcfSequenceDictionary \
    I=$vcf \
    O=$newvcf \
    SD=$seqdict
```

2. merge VCFs with the same sequence dictionary
```
vcf=
newvcf=
seqdict=
java -jar ~/software/picard/picard.jar mergeVcfs \
    I=$vcf \
    O=$newvcf \
    D=$seqdict
```
To merge multiple VCF, sample information on the row starting with "#CHROM" needs to be consistent.

