#!/usr/bin/perl -w
#
# ====================================================================================================
# File: fasta.reorganiz.pl
# Author: Sanzhen Liu
# Date: 9/8/2016
# ====================================================================================================

use strict;
use warnings;
use Getopt::Long;

my ($seq, $seq_name, %seqhash);
my ($fasta, $table, $bpperline, $header, $lclrm);
my $help;

sub prompt {
	print <<EOF;
	Usage: perl fasta.cancatenate.pl --fasta <Input Fasta Files> --table
	--fasta (str):		 fasta sequence file
	--table (str):		 reorganizing info file in the following format (6 columns separated by tab)
				 		(oldcontig	start	end	strand	newcontig	order)
	--bpperline(num):	bp per line, default=80
	--header:			table contains the header if specified (default: no header)
	--lclrm: 			rm "lcl|" from the beginning of each sequence name for BLAST/Genbank sort of format (default = not remove)
	--help:				help information
EOF
exit;
}
# read the parameters:
&GetOptions("fasta=s" => \$fasta, "table=s" => \$table, "bpperline=i" => \$bpperline,
			"header" => \$header, "lclrm" => \$lclrm, "help" => \$help) || &prompt;

if ($help) { &prompt; }
$bpperline = defined $bpperline ? $bpperline : 80;

###
### main
###
open(IN, $fasta) || die;
while (<IN>) {
	chomp;
	if (/^>(\S+)/) {
		if (defined $seq_name) {
			$seqhash{$seq_name} = $seq;
		}
    	$seq_name = $1;
		if ($lclrm) {
			$seq_name =~ s/lcl\|//g;
		}
		$seq = "";
 	 } else {
		$seq .= $_;
	}
}
# last element:
$seqhash{$seq_name} = $seq;
close IN;

### deal with each seq
my (@newseq, %newseq);
open(IN, $table) || die;
if ($header) {
	$_ = <IN>; ### skip first row
}
while (<IN>) {
	my @line = split(/\t/, $_);
	my ($oldctg, $start, $end, $strand, $newctg, $order) = @line;
	
	### extract sequences:
	my $frag;
	if (exists $seqhash{$oldctg}) {
		$frag = substr($seqhash{$oldctg}, $start - 1, $end - $start + 1);
		if ($strand eq "minus") {
			$frag = &revcom($frag);
		}
	} else {
		print "$oldctg does NOT exist\n";
		exit;
	}
	
	### add seqname to an array
	if (!exists $newseq{$newctg}) {
		push(@newseq, $newctg);
		print STDERR "$newctg\n";
	}
	
	### add sequence to hash
	$newseq{$newctg}{$order} = $frag;
}

### for each new sequence, merge according to the order and print
foreach my $eachnew (@newseq) {
	print ">$eachnew\n";
	my %newseq_order = %{$newseq{$eachnew}};
	my $eachnewseq;
	foreach (sort {$a <=> $b} keys %newseq_order) {
		$eachnewseq .= $newseq_order{$_};
	}
	&format_print($eachnewseq, $bpperline);
}

### module for formatted output:
sub format_print {
	my ($inseq, $formatlen) = @_;
	while (my $chunk = substr($inseq, 0, $formatlen, "")) {
		print "$chunk\n";
	}
}

### module for reverse complement sequences
sub revcom {
	my $ori_seq = shift @_; 
	my $revcomseq = reverse($ori_seq);
	$revcomseq =~ tr/AGCTagct/TCGAtcga/;
	return $revcomseq;
}

