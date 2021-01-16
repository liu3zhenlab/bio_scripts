# Primer ePCR
### Overview
The script takes a fasta file of primers and aligns each to a reference genome for all alignments allowing a few mismatches. With all the alignments, pairs of primers mapped to a certain region of a reference sequence (typically a chromosome) are identified and output.

### Dependency
[Perl](https://www.perl.org/)  
[bowtie](http://bowtie-bio.sourceforge.net)

### Data requirement
1. a primer fasta file, see an example in [primers.fas](primers.fas)
2. a fasta file of a reference, see an example in [ref.fas](ref.fas)

### Usage
```
Usage: primer.ePCR.pl [options]  
Options:  
  -p str  primer fasta file; required  
  -r str  bowtie index database; required  
  -m num  PCR min length (50)  
  -s num  PCR max length (10000)  
  -t num  maximum mismatches, must <=4 (3)  
          the penalty is 2 for the first 3 bases at 3' end   
  -b str  bowtie parameters, refer to bowtie-bio.sourceforge.net (-p 4 -B 1 -n 1 -y -v 2 -a -l 10 -f --best --quiet --sam-nohead)  
```

### Example
Here is an example that shows how to check primers in [primers.fas](primers.fas) on the [reference](ref.fas) .

First, the reference genome needs to be indexed.
```
bowtie-build ref.fas refdb
```

Second, run the script with the inputs and a primer fasta file and a Bowtie indexed database
```
#!/bin/bash
pfas=primers.fas
ref=refdb
prefix=out
perl primer.ePCR.pl -p $pfas -r $ref \
  1>${prefix}.txt 2>${prefix}.log
```

In the [output](out.txt), each pair islabeled to be uniquely or multiply mapped and the amplicon information is provided.
```
unique	pf1	AATTTTCGATCGATGCCTTG	0	+	ctg_1	888	pr1	GGGAATCCTCCCCTTCAATA	0	-	ctg_1	1125	238
multi3	pf2	CAGAGGATGGGAAGGCATAA	0	+	ctg_2	2485	pr2	ATAGGGTCTTGCCATGTTGC	0	-	ctg_2	2713	229
multi3	pf2	CAGAGGATGGGAAGGCATAA	0	+	ctg_2	665	pr2	ATAGGGTCTTGCCATGTTGC	0	-	ctg_2	2713	2049
multi3	pf2	CAGAGGATGGGAAGGCATAA	0	+	ctg_2	665	pr2	ATAGGGTCTTGCCATGTTGC	0	-	ctg_2	893	229
```
Note that unique indicates the primer pair can uniquely amplify a target; multi3 indicates that three reigons are targeted.


