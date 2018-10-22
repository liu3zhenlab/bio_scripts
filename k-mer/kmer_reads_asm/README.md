### kmer_reads_asm
A pipeline to identify and assemble reads harboring k-mers.

#### Prerequirement
1. seqtk
2. wgs assembler
**Note**:If these required commands are not in executable paths, add "export <path_to_script>" to the shell script.

#### specify input information
*subject to change*
```
kmers=CGACCACAGGCTCACACACCTCACC,ATGTGGGGTGAGGTGTGTGAGCCTG # a k-mer or k-mers separated by comma
infq1=example.R1.pair.fq
infq2=example.R2.pair.fq
outdir="example"
prefix_name="example"
srcdir=<path_to src>
```

#### produce some output file names based on the input information
*don't need to change*
```
infq1name=$(echo $infq1 | sed 's/.*\///g')
infq2name=$(echo $infq2 | sed 's/.*\///g')
outfq1=$prefix_name"_"$infq1name
outfq2=$prefix_name"_"$infq2name

### intermediate 
kmer_reads=$prefix_name"_read_list"
```

#### step 1. find reads harboring k-mers - kmer2fqreads.pl
*required data files*
1. kmers: sequences of a list of k-mers separated by comma
2. fastq_files: one fastq file or multple fastq files separated by comma
_Usage_: perl kmerseq2fqreadnames.pl --kmer <kmers separated by comma> --fastq <fastq_files separated by comma>
```
perl $srcdir/kmerseq2fqreadnames.pl --kmer $kmers --fastq $infq1,$infq2 | sort | uniq >  $kmer_reads
```

#### step 2. extract reads sequences
```
$srcdir/readnames2fqreads -l $kmer_reads -f $infq1 -s $infq2 -p $prefix_name -o $outdir -a $outfq1 -b $outfq2
```

#### step 3. assemble reads
```
if [ -d $outdir/asm_out ]; then
	rm -r $outdir/asm_out
else
	mkdir $outdir/asm_out
fi
$srcdir/fq2asm -f $outdir/$outfq1 -s $outdir/$outfq2 -o $outdir/asm_out -n $prefix_name 1>$prefix_name.fq2asm.log 2>&1
```

#### step 4. check assembly output
If contigs (ctg) are output, use contigs as the final assembled result. If contigs are not output and unitigs are produced, use unitigs (utg) as the final result. Otherwise, the assembly step is not successful.
```
asmout=$outdir/asm_out/9-terminator/$prefix_name
if [ -s $asmout".ctg.fasta" ]; then cp $asmout".ctg."* $outdir/; fi
if [ ! -s $asmout".ctg.fasta" ] && [ -s $asmout".utg.fasta" ]; then cp $asmout".utg."* $outdir/; fi
if [ ! -s $asmout".utg.fasta" ]; then echo "no successful assembly was output" >>$prefix_name.fq2asm.log; fi
```

#### suggestions for examining assemblied sequences
Multiple contigs (ctg) or unitigs (utg) could be generated. K-mers need to be matched with each assembled sequence to see which one carries which k-mer. Blastn could be used for this purpose or just manual checking. The read depth for each assembled sequence is on the sequence title, which provides useful information.

