#!/usr/bin/perl -w
# Sanzhen Liu
# 10/17/2018

use warnings;
use strict;
use Getopt::Long;

sub prompt {
	print <<EOF;
	Usage: perl single.kmer2readlist.pl --kmer <kmer> --fastq <fastq> [--help]
	Extract reads harboring a kmer sequence or its reverse-complement sequence
	--kmer : list of kmers separated by ","
	--fastq: list of fastq files separated by ","; Path included.
	--help 
EOF
exit;
}

my ($kmer, $fastq, $help);
# read the parameters:
&GetOptions("kmer=s" => \$kmer, "fastq=s" => \$fastq, "help" => \$help) || &prompt;

if ($help) { &prompt; }

my @kmer = split(/,/, $kmer);
my $kmer_common_seq = &commonseq(@kmer);
print STDERR "A common sequence was identified among all input kmers\n";
print STDERR "common sequence = ", $kmer_common_seq, "\n";

my $kmer_common_seqrc = &revcom($kmer_common_seq);

my @fastq = split(/,/, $fastq);

my ($readname);
foreach my $input (@fastq) {
	my $nr = 0;
	open(IN, $input) || die;
	while (<IN>) {
		$nr++;
		chomp;
		if ($nr % 4 == 1) {
			$readname = $_;
		}
		if ($nr % 4 == 2) {
			if (/$kmer_common_seq/ or /$kmer_common_seqrc/)  {
				for my $ekmer (@kmer) {
					my $ekmer_rc = &revcom($ekmer);
					if (/$ekmer/ or /$ekmer_rc/) {
						$readname =~ s/\@//g;
						$readname =~ s/ .*//g;
						print "$readname\n";
					}
				}
			}
		}
	}
}

sub revcom {
# reverse complementary
	my $inseq = shift @_;
	my $revcom = reverse($inseq);
	$revcom =~ tr/AGCTagct/TCGAtcga/;
	return $revcom;
}

sub commonseq {
# identify common sequences among multiple sequences
	my $max_counts_seq = "";
	my @inseq = @_;
	my $inseq_minlen = &minlen(@inseq);
	my %seqcounts;
	for (my $i=$inseq_minlen; $i >= 5; $i--) {
		foreach my $eachseq (@inseq) {
			my $splitted = &strsplit($eachseq, $i);
			my @splitted_seq = @{$splitted};
			foreach my $uniqseq (@splitted_seq) {
				$seqcounts{$uniqseq}++;
			}
		}

		my $max_counts;
		my $max_counts_seq;
		foreach my $aseq (sort {$seqcounts{$b} <=> $seqcounts{$a}} keys %seqcounts) {
			$max_counts = $seqcounts{$aseq};
			$max_counts_seq = $aseq;
			last;
		}
		if ($max_counts == ($#inseq + 1)) {
			return $max_counts_seq;
			last;
		}
	}
}

sub minlen {
# minimum length of a set of sequences
	my @inseq = @_;
	my $minbp = 10000000;
	foreach (@inseq) {
		if (length($_) < $minbp) {
			$minbp = length($_);
		}
	}
	return $minbp;
}

sub strsplit {
# input a sequence and length of subseq to extract (two variables) 
	my %splitseqhash;
	my ($seq, $len) = @_;
	my $seqlen = length($seq);
	my $seqrc = &revcom($seq);
	for (my $i=0; $i<=($seqlen - $len); $i++) {
		my $splitsubseq = substr($seq, $i, $len);
		my $splitsubseqrc = substr($seqrc, $i, $len);
		$splitseqhash{$splitsubseq}++;
		$splitseqhash{$splitsubseqrc}++;
	}
	my @splitseqarray = keys %splitseqhash;
	return \@splitseqarray;
}
