### Repeatmask

#### exmample
```
#!/bin/bash
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=1-00:00:00
repdb=/bulk/liu3zhen/research/A188asm/32-maker/0-data/A188v1.fasta.EDTA.TElib.fa
out=tig00014116.fasta
#ln -s $infas $out 
RepeatMasker -pa 8 -lib $repdb -gff $out -u 1>1o-RM.log 2>&1
### format output
cat $out.out | sed 's/^ \+//g' | sed 's/ \+/\t/g' > $out.out.txt
```
