#!/usr/bin/perl -w

use warnings;
use strict;

foreach my $input (@ARGV) {
	my $bases;
	my $nr = 0;
	open(IN, $input) || die;
	while (<IN>) {
		$nr++;
		chomp;
		if ($nr % 4 == 2) {
			if (!/^[AGCTNacgtn]+$/) {
				print "Line $nr is not DNA sequence:\n$_\n";
				last; }
			$bases = length($_);
			print "$bases\n";
		}
	}
}
