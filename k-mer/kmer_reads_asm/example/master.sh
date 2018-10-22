### kmer_asm
### Sanzhen Liu
### 10/19/2018

##########################################
### input, subject to change
kmers=CGACCACAGGCTCACACACCTCACC,ATGTGGGGTGAGGTGTGTGAGCCTG # a k-mer or k-mers separated by comma
infq1=example.R1.pair.fq
infq2=example.R2.pair.fq
outdir="example"
prefix_name="example"
srcdir=<path_to src>
##########################################
infq1name=$(echo $infq1 | sed 's/.*\///g')
infq2name=$(echo $infq2 | sed 's/.*\///g')
outfq1=$prefix_name"_"$infq1name
outfq2=$prefix_name"_"$infq2name

### intermediate 
kmer_reads=$prefix_name"_read_list"

#### step 1. find reads rboring k-mers
perl $srcdir/kmerseq2fqreadnames.pl --kmer $kmers --fastq $infq1,$infq2 | sort | uniq >  $kmer_reads

### step 2. extract reads sequences
$srcdir/readnames2fqreads -l $kmer_reads -f $infq1 -s $infq2 -p $prefix_name -o $outdir -a $outfq1 -b $outfq2
#rm $kmer_reads

### step 3. assemble reads
if [ -d $outdir/asm_out ]; then
	rm -r $outdir/asm_out
else
	mkdir $outdir/asm_out
fi
$srcdir/fq2asm -f $outdir/$outfq1 -s $outdir/$outfq2 -o $outdir/asm_out -n $prefix_name 1>$prefix_name.fq2asm.log 2>&1

### step 4. check output
asmout=$outdir/asm_out/9-terminator/$prefix_name
if [ -s $asmout".ctg.fasta" ]; then cp $asmout".ctg."* $outdir/; fi
if [ ! -s $asmout".ctg.fasta" ] && [ -s $asmout".utg.fasta" ]; then cp $asmout".utg."* $outdir/; fi
if [ ! -s $asmout".utg.fasta" ]; then echo "no successful assembly was output" >>$prefix_name.fq2asm.log; fi

