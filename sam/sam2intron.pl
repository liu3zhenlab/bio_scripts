#!/usr/bin/perl -w 
# sam2intron.pl
# Sanzhen Liu
# 7/18/2011

use strict;
use warnings;
use Getopt::Long;

my ($infile, $source, $help);
GetOptions("input|i=s" => \$infile, "source|s=s" => \$source, "help|h" => \$help);

if ($help) { &errInf; }

sub errInf {
print <<EOF;
Usae: perl sam2intron.pl -i [SAM file] -s [source string]
		Options
		--input|i: SAM file
		--source|s: string to add in the header
		--help: print help information
EOF
exit;
}

if (!defined $infile) {
	&errInf;
}

if (!defined $source) {
	$source = $infile;
}

#print header:
print "chr\tintronStart\tintronEnd\t$source\n";
my (%intron, @line, $chr, $start);
open(IN,$infile) || die;
while (<IN>) {
	if (!/^@/) {
		chomp;
		@line = split(/\t/,$_);
		$chr = $line[2];
		$start = $line[3];
		my $align = $line[5]; # alignment summary
		if ($align =~ /N/) {
			my @large_gap = split(/N/,$align);
			my $pos = $start;
			for (my $i=0; $i<$#large_gap; $i++) {
				$large_gap[$i] =~ /(\d+)$/;
				my $intron_size = $1;
				my @typecount = split(/[MIDSHP]/,$large_gap[$i]); # array of matched, gap bases and so on
				$large_gap[$i] =~ s/[0-9]//g; # remove those number
				my @type = split(//,$large_gap[$i]);
				for (my $i=0; $i<=$#type; $i++) {
					# gap, deletion:
					if ($type[$i] =~ /[MD]/) {  # deletion
						$pos+=$typecount[$i];
					}
				} # end FOR
				my $intron_start = $pos;
				my $intron_end = $pos+$intron_size-1;
				$pos = $intron_end + 1;
				$intron{$chr}{$intron_start}{$intron_end}++;
			}
		}
	}
} # end of while <IN>
close IN;

# output for each chr:
foreach my $each_chr (sort {$a cmp $b} keys %intron) {
	my %chr_introns = %{$intron{$each_chr}};
	foreach my $each_start (sort {$a <=> $b} keys %chr_introns) {
		my %end_counts = %{$chr_introns{$each_start}};
		foreach my $each_end (sort {$a <=> $b} keys %end_counts) {
			print "$each_chr\t$each_start\t$each_end\t$end_counts{$each_end}\n";
		}
	}
}


