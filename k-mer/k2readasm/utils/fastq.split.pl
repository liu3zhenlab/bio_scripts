#!/usr/bin/perl -w

# author: Sanzhen Liu
# 9/15/2020

use strict;
use warnings;
use Getopt::Long;

my $prefix = "reads";
sub prompt {
	print <<EOF;
	Usage: perl $0 --fq1 <fastq> --fq2 <fastq> --npart <num>
	--fq1 <file>  : fastq 1 of the pair (required)
	--fq2 <file>  : fastq 2 of the pair (optional)
	--prefix <str>: prefix for fastq output
	--npart <num> : number of partitions (required)
	--help        : help informatoin
EOF
exit;
}

my %opts = ();
&GetOptions(\%opts, "fq1=s", "fq2=s",
                    "npart=i", "prefix=s", "help");

&prompt if exists $opts{help} or !%opts;

if (!exists $opts{fq1} or !exists $opts{npart}) {
	print STDERR "--fq1 and --npart are required\n";
}

my $fq1 = $opts{fq1} if (exists $opts{fq1});
my $fq2 = $opts{fq2} if (exists $opts{fq2}); 
my $npart = $opts{npart} if (exists $opts{npart}); 
$prefix = $opts{prefix} if (exists $opts{prefix});

my $nfq1=`wc -l $fq1 | sed 's/ .*//g'`;
chomp $nfq1;

my $unit = int($nfq1 / 4 / $npart); # reads in each unit

my (@starts, @ends, @ids); # row start and end in each split file
for (my $i=1; $i<=$npart; $i++) {
	my $start = ($i - 1) * $unit * 4 + 1;
	my $end = $i * $unit * 4;
	if ($i == $npart) {
		$end = $nfq1;
	}
	
	push(@starts, $start);
	push(@ends, $end);
	push(@ids, $i);
}

my $nfile = 0;
my $count = 0;
my $partfq1;
open (IN, "<", $fq1) || die;
while (<IN>) {
	$count++;
	
	# if the row number is larger than the end, do:
	if ($count>$ends[$nfile]) {
		close FQ1;
		$nfile++; # go next
	}
	
	# if the row number matches the start, do:
	if ($count==$starts[$nfile]) {
		my $id = $nfile + 1;
		$partfq1 = $prefix."_".$id."_1.fq";
		open(FQ1, ">", $partfq1) || die;
	}

	# if in the range, do:
	if (($count>=$starts[$nfile]) and ($count<=$ends[$nfile])) {
		if (/^\@/ and (($count % 4) == 1)) {
			print FQ1 "$_";
			for (my $i=0; $i<3; $i++) {
				$_ = <IN>;
				print FQ1 "$_";
				$count++;
			}
		}
	}
}
close IN;

$nfile = 0;
$count = 0;
my $partfq2;
open (IN, "<", $fq2) || die;
while (<IN>) {
	$count++;

	# if the row number is larger than the end, do:
	if ($count>$ends[$nfile]) {
		close FQ2;
		$nfile++; # go next
	}
	
	# if the row number matches the start, do:
	if ($count==$starts[$nfile]) {
		my $id = $nfile + 1;
		$partfq2 = $prefix."_".$id."_2.fq";
		open(FQ2, ">", $partfq2) || die;
	}


	# if in the range, do:
	if (($count>=$starts[$nfile]) and ($count<=$ends[$nfile])) {
		if (/^\@/ and (($count % 4) == 1)) {
			print FQ2 "$_";
			for (my $i=0; $i<3; $i++) {
				$_ = <IN>;
				print FQ2 "$_";
				$count++;
			}
		}
	}
}
close IN;

