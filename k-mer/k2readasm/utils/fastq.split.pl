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

for (my $i=1; $i<=$npart; $i++) {
	my $start = ($i - 1) * $unit * 4 + 1;
	my $end = $i * $unit * 4;
	if ($i == $npart) {
		$end = $nfq1;
	}
	my $nrows = $end - $start + 1;

	my $partfq1 = $prefix."_".$i."_1.fq";
	my $partfq2 = $prefix."_".$i."_2.fq";
	
	`head -n $end $fq1 | tail -n $nrows > $partfq1`;
	`head -n $end $fq2 | tail -n $nrows > $partfq2`;
}
=cut
my $count = 0;
open (IN, "<", $fq1) || die;
while (<IN>) {
	chomp;
	if (/^\@/ and (($count % 4) == 0)) {
		$count++;
		if ($count>=$ARGV[1] and $count<=$ARGV[2]) {
			print "$_\n";
			for (my $i=0; $i<3; $i++) {
				$_ = <IN>;
				print "$_";
			}
		} elsif ($count>$ARGV[2]) {
			last;
		}
	}
}
close IN;
}
