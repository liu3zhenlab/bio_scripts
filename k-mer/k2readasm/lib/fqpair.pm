#!/usr/bin/perl -w

package fqpair;
use strict;
use warnings;

# fqpair.pm
# Sanzhen Liu
# 9/15/2020

sub fqpair {
# input two paired fastq
# output 1 or 0 to indicate if two fq were paired or not.
	my ($infq1, $infq2) = @_;
	my (@read1, @read2);
	
	### pair 1
	my $row = 0;
	open(IN, $infq1) || die;
	while (<IN>) {
		chomp;
		if (/^\@(\S+)/ and ($row % 4) == 0) {
			my $common_name = $1;
			$common_name =~ s/\/[1-2]$//;
			push(@read1, $common_name);
		}
		$row++;
	}
	close IN;

	### pair2
	$row = 0;
	open(IN, $infq2) || die;
	while (<IN>) {
		chomp;
		if (/^\@(\S+)/ and ($row % 4) == 0) {
			my $common_name = $1;
			$common_name =~ s/\/[1-2]$//;
			push(@read2, $common_name);
		}
		$row++;
	}
	close IN;
	
	# paired
	my $well_paired = 1;
	if ($#read1 != $#read2) {
		$well_paired = 0;
	} else {
		# compared each name
		for (my $i=0; $i<=$#read1; $i++) {
			if ($read1[$i] ne $read2[$i]) {
				$well_paired = 0;
				last;
			}
		}
	}
	# output
	return $well_paired;
}

1;

