#!/usr/bin/perl -w

########################################################
# kmer2readname.pm
# Sanzhen Liu
# 9/14/2020
########################################################

package kmer2readname;
use warnings;
use strict;

sub kmer2rn {
	# input: <kmer_table> <out_kmer_readname> <out_readname> <fastq_files> 
	# <kmer_table> has two colums separated by a tab: kmer ID and kmer sequences
	my @input = @_;
	my $inkmer_file = $input[0]; # kmers;  cols
	my $outkrn_file = $input[1]; # output filename for kmer ID, kmer seq, and readnames
	my $outrn_file = $input[2]; # output filename for readnames
	my @in_readfiles = @input[3..$#input]; # input fastq files
	my %readname;
	my %kmer;
	
	open(KRN, ">", $outkrn_file) || die; # kmer-reads
	open(RN, ">", $outrn_file) || die; # reads
	
	# kmer file
	open(KMER, $inkmer_file) || die;
	while (<KMER>) {
		chomp;
		my @line = split(/\t/, $_);
		$kmer{$line[0]} = $line[1];
	}

	my ($previous_line, $kmer_seq, $kmer_rcseq);
	foreach my $input (@in_readfiles) {
		my $nr = 0;
		open(IN, $input) || die;
		while (<IN>) {
			$nr++;
			chomp;
			if ($nr % 4 == 1) {
				$previous_line = $_;
			}
			if ($nr % 4 == 2) {
				for my $kmername (keys %kmer) {
					$kmer_seq = $kmer{$kmername};
					$kmer_rcseq = &revcom($kmer_seq);
					if (/$kmer_seq/ or /$kmer_rcseq/) {
						$previous_line =~ s/^\@//g;
						$previous_line =~ s/\/[12]$//g;
						$previous_line =~ s/ .*//g;
						$readname{$previous_line}++;
						print KRN "$kmername\t$kmer_seq\t$previous_line\n";
					}
				}
			}
		}
	}
	# output read list:
	foreach (keys %readname) {
		print RN "$_\n";
	}

	close KRN;
	close RN;
}
sub revcom {
	my $inseq = shift @_;
	my $revcom = reverse($inseq);
	$revcom =~ tr/AGCTagct/TCGAtcga/;
	return $revcom;
}

1;

