
### gene2regionalBAM

*an example to extract BAM data of a v4 gene for members in Liu Lab*
```
example_gene=Zm00001d018635
bedfile=/home/liu3zhen/references/B73refgen4/genemodel/B73Ref4.gene.bed
alnpath=/data1/home/liu3zhen/newB73Mo17WGS/v4alignment

gene2regionalBAM -g $example_gene -b $bedfile -d $alnpath
```
