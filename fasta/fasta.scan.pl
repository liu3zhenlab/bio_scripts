#!/usr/bin/perl
### fasta.scan.pl
### Sanzhen Liu
### Kansas State University
### 6/8/2014

use warnings;
use strict;
use File::Basename;
use Getopt::Long;

###################################################################################
sub prompt {
### help information
	print <<EOF;
	Usage: perl fasta.scan.pl --fasta <fasta file> [other options]
	[win]:		integer, windown size, default=100 bp
	[step]:		integer, step size, default=50 bp
	[feature]:	string, to indicate the module to run, the modules
				include the default "gc" (GC%) and ... (add later)
	[help]:		help information
EOF
exit;
}
###################################################################################

###################################################################################
sub gc {
### determine the GC% for the input sequence
	my ($in_seq, $in_name) = @_;
	$in_seq = uc($in_seq);
	my $size = length($in_seq);
	$in_seq =~ s/N//ig;
	my $size_noN = length($in_seq);
	my $size_N = $size - $size_noN;
	$in_seq =~ s/[AT]//ig;
	my $size_gc = length($in_seq);
	$in_seq =~ s/[GC]//ig;
	my $leftover_size = length($in_seq);
	if ($leftover_size > 0) {
		print STDERR "WARNING: characters other than AaTtGgCcNn occur in the $in_name"; 
	}
	
	my $size_ATGC = ($size_noN - $leftover_size);
	my $gc_perc = "NA";
	if ($size_ATGC > 0) {
		$gc_perc = ($size_gc/$size_ATGC);
	}
	return $gc_perc;
}
###################################################################################

my ($help, $fasta, $win, $step, $feature);

&GetOptions("help" => \$help,
			"fasta=s" => \$fasta,
			"win=i" => \$win,
			"step=i" => \$step,
			"feature=s" => \$feature) || &prompt;

###
### print help information
###
if ($help) {
	&prompt;
}

###
### set up default values
###
$win = 100 if (!defined $win);
$step = 50 if (!defined $step);
$feature = "gc" if (!defined $feature);

###
### read all the sequences:
###
my %seqs;
$/ = ">"; # setup input separator
open (FASTA, "<$fasta") || die;
my $junk = (<FASTA>); ### split the file by ">", first one is empty, discarded
while (my $frecord = <FASTA>) {
	chomp $frecord;
	my ($fdef, @seqLines) = split /\n/, $frecord;
	my $seq = join '', @seqLines;
	$seqs{$fdef} = $seq;
}
close FASTA;

###
### scan each sequence and determine the feature
###
foreach my $fa_name (keys %seqs) {
	my $cur = $seqs{$fa_name};
	my $start = 0;
	my $cur_win = substr($cur, $start, $win);
	
	### start to scan
	while (length($cur_win) == $win) {
		my $start_1based = $start + 1; ### window start
		my $end_1based = $start + $win; ### window end
		my $cur_win_info = $fa_name."_win-start-at_".$start_1based;  ### provide window information
		if ($feature eq "gc") {
			my $cur_gc_perc = &gc($cur_win, $cur_win_info);
			print "$fa_name\t$start_1based\t$end_1based\t$cur_gc_perc\n";
		}
		$start += $step;
		$cur_win = substr($cur, $start, $win);
	}
}

