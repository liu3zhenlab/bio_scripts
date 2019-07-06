#!/usr/bin/perl -w
use strict;
use warnings;
use File::Temp;
use Getopt::Long;

my ($mem, $time, $bampaths, $help);
my ($threads, $checkscript);
my ($ref, $maxlen, $java, $outbase, $selectseq);
my $result = &GetOptions("mem=s" => \$mem,
                        "time=s" => \$time,
			"threads=i" => \$threads,
			"bampaths=s" => \$bampaths,
			"ref=s" => \$ref,
			"selectseq=s" => \$selectseq,
			"java=s" => \$java,
			"outbase=s" => \$outbase,
			"maxlen=i" => \$maxlen,
			"help" => \$help,
			"checkscript" => \$checkscript);

#0: preparation:
$mem = "24G" if !defined $mem;
$time = "0-23:59:59" if !defined $time;
$threads = 1 if !defined $threads;
$maxlen = 1000000 if !defined $maxlen;
$java = "Java/1.8.0_192" if !defined $java;

if (!defined $bampaths) {
	print STDERR "PATH to BAM files are required\n";
	&prompt;
}

if (!defined $ref) {
	print STDERR "Reference sequence file is required.\n";
	print STDERR "Index files with suffix with .dict and .fai are needed, which must be\n";
	print STDERR "under the same directory with the sequencine file\n";
	&prompt;
}

if (!defined $outbase) {
	print STDERR "the parameters outbase is required\n";
	&prompt;
}

&prompt if ($help);

my $curtime = localtime;
$curtime =~ s/[ :]//g;
my $outdir = $outbase."_".$curtime;
my $maindir = $outdir."/main";
my $logdir = $outdir."/logs";
my $vcfdir = $outdir."/vcfs";

if (-d $outbase) {
	print STDERR "Output directory $outdir exists.\n";
	&prompt;
} else {
	system(sprintf("%s%s", "mkdir ", $outdir)); # create output directory 
	system(sprintf("%s%s", "mkdir ", $maindir));
	system(sprintf("%s%s", "mkdir ", $logdir));
	system(sprintf("%s%s", "mkdir ", $vcfdir));
}

#1: bam list
#$bamlist = File::Temp->new(SUFFIX => '.bamtmp');
my $bamlist = $maindir."/".$outbase.".bamlist";
my @bampaths = split(/\s|,/, $bampaths);
my $bamgen_cmd;
if (-e $bampaths[0] and -d $bampaths[0]) {
	$bamgen_cmd=sprintf("%s%s%s%s", "ls ", $bampaths[0], "/*bam -1 | sed 's/^/-I /g' > ", $bamlist);
	system($bamgen_cmd);
}

# multiple paths:
if ($#bampaths > 0) {
	print "$bampaths[1]\n";
	for (my $i=1; $i<=$#bampaths; $i++) {
		if (-e $bampaths[$i] and -d $bampaths[$i]) {
			$bamgen_cmd=sprintf("%s%s%s%s", "ls ", $bampaths[$i], "/*bam -1 | sed 's/^/-I /g' >> ", $bamlist);
			system($bamgen_cmd);
			print STDERR "$bamgen_cmd\n";
		}
	}
}

#2:partition sequences and regions:
#2.1:file containing sequnence names 
my %selseq;
if (defined $selectseq) {
	open(IN, $selectseq) || die;
	while(<IN>) {
		chomp;
		$selseq{$_}++;
	}
	close IN;
}

#2.2:dict file of the reference
my $dict = $ref;
$dict =~ s/fa$|fas$|fasta$/dict/;

# @SQ	SN:1	LN:307041717
#my $partition = File::Temp->new(SUFFIX => '.partition.tmp');
my $partition = $maindir."/".$outbase.".partition.txt";
my $total_jobnum = 0;
open(OUT, ">$partition") || die;
open(IN, $dict) || die;
while (<IN>) {
	chomp;
	if (/^\@SQ\tSN\:([^\t]+)\tLN\:(\d+)/) {
		my $seqname = $1;
		my $seqlen = $2;
		if (! %selseq or exists $selseq{$seqname}) {
			if ($seqlen <= $maxlen) {
				print OUT "$seqname:1-$seqlen\n";
				$total_jobnum++;
			} else {
				my $num_partitions = int($seqlen / $maxlen) + 1;
				my $start = 1;
				for (my $i=1; $i<$num_partitions; $i++) {
					my $end = $i * $maxlen;
					print OUT "$seqname:$start-$end\n";
					$start += $maxlen;
					$total_jobnum++;
				}
				print OUT "$seqname:$start-$seqlen\n";
				$total_jobnum++;
			}
		}
	}
}
close IN;
close OUT;


#3.GATK script
my $gatkfile = $maindir."/".$outbase.".gatk.HaplotypeCaller.sh";
open(GATK, ">$gatkfile") || die;
# memory
my $mem_num = $mem;
$mem_num =~ s/[Gg]//g;
my $total_mem = $mem_num * $threads;
$total_mem .= "g";
print GATK  "#!/bin/bash -l\n";
print GATK "module load $java\n";
print GATK "interval=\`head $partition -n \$SLURM_ARRAY_TASK_ID | tail -n 1\`\n";
print GATK "vcfout=$vcfdir\/$outbase.\$SLURM_ARRAY_TASK_ID.vcf\n";
print GATK "gatk HaplotypeCaller --java-options \'-Xmx$total_mem\' -R $ref --arguments_file $bamlist --intervals \$interval -O \$vcfout\n";

#4. merge VCF
my $mergesh = $maindir."/".$outbase.".gatk.MergeVcfs.sh";
open(MERGE, ">$mergesh") || die;
print MERGE  "#!/bin/bash -l\n";
print MERGE "module load $java\n";
my $vcflist = $maindir."/".$outbase.".vcf.list";
print MERGE "ls $vcfdir/*vcf -1 > $vcflist\n";
# completeness checking
my $final_log = $outdir."/".$outbase.".log";
print MERGE "npartitions=`wc -l $partition | sed 's/ .*//g'`\n";
print MERGE "echo \"Number of partitions is \"\$npartitions > $final_log\n";
print MERGE "nvcf=`wc -l $vcflist | sed 's/ .*//g'`\n";
print MERGE "echo \"Number of vcf files is \"\$nvcf >> $final_log\n";
print MERGE "nidx=`ls $vcfdir/*vcf.idx -1 | wc -l | sed 's/ .*//g'`\n";
print MERGE "echo \"Number of vcf indexed files is \"\$nidx >> $final_log\n";

my $finalvcf = $outdir."/".$outbase.".vcf";
print MERGE "gatk MergeVcfs -I $vcflist -O $finalvcf\n";
close MERGE;

#5. SBATCH script
my $gatk_sbatchfile = $maindir."/".$outbase.".gatk.sbatch.scripts.sh";
open(SCPT, ">$gatk_sbatchfile") || die;
print SCPT "ajobinfo=\$(sbatch \\\n";
print SCPT "--array=1-$total_jobnum \\\n";
print SCPT "--job-name=GATK.$outbase \\\n";
print SCPT "--output=$logdir/%j_%A_%a.out \\\n";
print SCPT "--error=$logdir/%j_%A_%a.err \\\n";
print SCPT "--cpus-per-task=$threads \\\n";
print SCPT "--mem-per-cpu=$mem \\\n";
print SCPT "--time=$time \\\n";
print SCPT "$gatkfile)\n";
print SCPT "ajobid=`echo \$ajobinfo | sed 's/.* //g'`\n";

# sbatch to run merge cmd
my $merge_mem = $mem_num * $threads * 4;
$merge_mem = 48 if ($merge_mem < 48);
$merge_mem = 216 if ($merge_mem > 216);
$merge_mem .= "G";

print SCPT "sbatch \\\n";
print SCPT "--dependency=afterany:\$ajobid \\\n";
print SCPT "--job-name=merge.$outbase \\\n";
print SCPT "--output=$logdir/vcfmerge.%j.out \\\n";
print SCPT "--error=$logdir/vcfmerge.%j.err \\\n";
print SCPT "--cpus-per-task=$threads \\\n";
print SCPT "--mem-per-cpu=$merge_mem \\\n";
print SCPT "--time=$time \\\n";
print SCPT "$mergesh\n";
close SCPT;

# sbatch scripts
my $sbatch_cmd = sprintf("%s%s", "sh ", $gatk_sbatchfile);
if (!$checkscript) {
   system($sbatch_cmd);
}

sub prompt {
	print <<EOF;
	Usage: perl gatk.sbatch.pl --ref <fasta> --bampaths <path-to-bam> --outbase <base of outputs> [options]

	Options:
	--outbase <base name>: base for all outputs, required
	--ref <ref fasta file>: path to the reference fasta file with suffix of "fa", "fas", or "fasta
	       directory containing this file also has its indexed files: .dict and .fai
	--bampaths <paths containing BAM files>: paths to directories containing bam files; required
	--mem <memory>: memory per thread/cpu; default=24G
	--time <time>: running time for each array subjob; default=0-23:59:59
	--threads <num>: running thread per job; default=1
	--selectseq <file containing names of targeted sequences>: equence names for variant discovery;
	  one per line. All sequences will be used if no file is provided.
	--java <java module>: Java module; default=Java/1.8.0_192
	--maxlen <max length>: maximal interval length of each job to call variants; default=2000000
	--checkscript: only produce scripts/files and no SBATCH run
	--help: helping information
EOF
exit;
}

