#!/usr/bin/perl -w
# Sanzhen Liu
# 8/26/2015

use strict;
use warnings;

# open the file:
open(IN, $ARGV[0]) || die;
while (<IN>) {
	if (!/\#\#/) {
		my %fd = (); # initiate fd, format-depristo
		my @t = split;
   		if (/^\#CHROM/) {
			print "CHR\t";
			print join("\t", @t[1,3,4,5]);
			for (my $i=9; $i<= $#t; $i++) {
				printf("\t%s%s\t%s%s", $t[$i], "_REF", $t[$i], "_ALT");
			}
			print "\n";
			next;
		}
		next if ($t[4] eq '.'); # skip non-var sites
   		next if ($t[3] eq 'N'); # skip sites with unknown ref ('N')
		
		print join("\t", @t[0, 1, 3, 4, 5]);

		my @format = split(/:/, $t[8]); # format column
		for (my $k = 9; $k <= $#t; $k++) {
			my @depristo = split(/:/, $t[$k]);
			for (my $i=0; $i<=$#format; $i++) {
				if (!exists $depristo[$i]) {
					$depristo[$i] = "NA";
				}
				$fd{$format[$i]} = $depristo[$i];
			}
			if (exists $fd{AD}) {
				my @ad = split(/,/, $fd{AD}); # allele depth
				my $refc = "NA";
				my $altc = "NA";
				if ($#ad >= 1) {
					$refc = $ad[0]; # ref count
					$altc = $ad[1]; # alt count
				}
				print "\t$refc\t$altc";
			} else {
				print STDERR "ERROR:";
				print STDERR "$_\n";
				print STDERR "No AD data, AD=allele depth\n";
				exit;
			}
		}
		print "\n";
	}
}

close IN;

