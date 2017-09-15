#!/usr/bin/perl -w

# File: samparser.pl
# Author: Sanzhen Liu (modified from Eddy's gsnap2gff3.pl)
# 2/28/2011 (initial day)
# 8/31/2011 (updated)

use strict;
use warnings;
use FileHandle;
use Getopt::Long;

use constant CURRENT_VERSION => "0.03beta (2011.6.24)";
#use constant VERSION => "0.02beta (2011.6.12)";
use constant DEFAULT_MIN_IDENTICAL => 30;       # Default minimum identical length per read
use constant DEFAULT_MAX_MISMATCHES => 2;		# Default maximum mismatches per read
use constant DEFAULT_MAX_TAIL => 3;				# Default maximum tail allowed
use constant DEFAULT_MAX_GAP => 10000; 			# Default maximum gap allowd
use constant INDEL_PENALTY => 2;
use constant DEFAULT_INSERT_MIN => 100;         # Default minimal insert length
use constant DEFAULT_INSERT_MAX => 600;         # Default maximal insert length

my ($file, @mismatches, @maxtail, $help, $maxgap, $identical,
	$mappingscore, @insert, $keep_chimeric_paired);
my $result = &GetOptions("input|i=s" => \$file,
					     "identical|e=i" => \$identical,
                         "mismatches|m|mm:i{1,2}" => \@mismatches,
						 "tail|t:i{1,2}" => \@maxtail,
						 "gap|g=i" => \$maxgap,
						 "mappingscore=i" => \$mappingscore,
						 "insert:i{1,2}" => \@insert,
						 "keep_chimeric_paired" => \$keep_chimeric_paired,
						 "help|h" => \$help
);

# print help information if errors occur:
if ($help) {
	&errINF;
	exit;
}

# Assigning default program parameters

# identical length:
if (!defined $identical) {
	$identical = DEFAULT_MIN_IDENTICAL;
}
# mismatch
if (scalar(@mismatches) == 0) {
	push(@mismatches, DEFAULT_MAX_MISMATCHES);
} # End of if statement

# tail parameter:
if (scalar(@maxtail)==0) {
	push(@maxtail,DEFAULT_MAX_TAIL); # setup default
}

# gap parameter:
if (!defined $maxgap) {
	$maxgap = DEFAULT_MAX_GAP;
}

# mimimum mapping score:
if (!defined $mappingscore) {
	$mappingscore = 40;
}

## length range of inserts
if (scalar(@insert)==0) {
	@insert = (DEFAULT_INSERT_MIN, DEFAULT_INSERT_MAX);
}

my ($identicalpass, $mmpass, $tailpass, $gappass, $mappingscore_pass, $pe_insert_pass, $var_num);
my (%total_read_count, %mapped_read_count, %unmapped_read_count, %confident_mapped_read_count); 
# open the input sam file:
open (IN, $file) or die("Cannot open the SAM file $file\n");
while (<IN>) {
	chomp;
	if (!/^@/) { # not header
		$identicalpass = 0; # to judge identical length
		$mmpass = 0; # to judge mismatch
		$tailpass = 0; # to judge tail length
		$gappass = 0; # to judge gap length
		$mappingscore_pass = 0; # to judge maximum number of read alignment
		$pe_insert_pass = 1; # to judge the length of insert

		my @line = split(/\t/,$_);
		$total_read_count{$line[0]}++;	
		my $flag = $line[1];
		# if (!($line[1]==4 or decode($line[1],4))) { # mapped?
		if (!($flag & 4)) { # mapped
			$mapped_read_count{$line[0]}++;
			my $aligncode = $line[5];
		#*** criterion: gap ***
			my @gap = split(/N/,$aligncode); # N represents skip region
			my $gap_len = 0;
			foreach my $part (@gap) {
				if ($part =~ /(\d+)$/) {
					$gap_len += $1;
				}
			}
			if ($gap_len<=$maxgap) {
				$gappass = 1;
			}
		### criterion: gap ###

		#*** criterion: mismatch (edit distance, mismatches, insertions and deletions) ***
			my $readseq = $line[9];
		
			## number of "N":
			my $readlen_raw = length($readseq);
			$readseq =~ s/N//g;
			my $readlen_after = length($readseq);
			#my $n_num = $readlen_raw - $readlen_after; # number of "N" in reads
		
		## bp of matched region (note: matched region contains mismatch bp)
			my $match_len = 0;
			my @match = split(/M/,$aligncode);
			foreach my $part (@match) {
				if ($part =~ /(\d+)$/) {
					$match_len += $1;
				}
			}
		
		## criterion: mapping score:
			my $mapped_score = $line[4];
			if ($mapped_score >= $mappingscore) {
				$mappingscore_pass = 1;
			}
		
		### criterion: insert length ###
		### DO NOT allow read paired from different chromosomes
			my $insert_len = abs($line[8]);
			my $pair_sign = $line[6]; ### *,=,or chromosome name if a pair was mapped to different chromosome
			if ($pair_sign eq "=") {
				if ($insert_len > $insert[1] or $insert_len < $insert[0]) {
					$pe_insert_pass = 0;
				}   
			} elsif (!$keep_chimeric_paired and $pair_sign ne "*" and $pair_sign ne $line[2]) { ### map to different chromosomes
				$pe_insert_pass = 0;
			} 
		### criterion: insert length ###

		## criterion: mismatch
			if ($_ =~ /NM\:i\:(\d+)/) { # GSNAP081511 version doesn't include INDEL in the NM information
				$var_num = $1; # just mismatch information
				my $indel = $aligncode;
				$indel =~ s/[ID]//g;
				my $indel_penalty = (length($aligncode) - length($indel)) * INDEL_PENALTY;
				my $actual_var_num = $var_num + $indel_penalty;
			# filter:
				if (scalar(@mismatches)==1 and $actual_var_num<=$mismatches[0]) {
					$mmpass = 1;
				} elsif (scalar(@mismatches)==2 and ($actual_var_num/$match_len)<=($mismatches[0]/$mismatches[1])) {
					$mmpass = 1;
				}
			} else {
				print STDERR "WARNING: $line[0] DONOT have NM (number of match) information.\n";
			}
		### criterion: mismatch  ###
		
		#*** identical length ***
			if (($match_len-$var_num)>=$identical) {
				$identicalpass = 1;
			}
		### criterion: identical ###

		#*** criterion: tail ***
			my @tail = split(/S/,$aligncode);
			my $tail = 0;
			foreach my $part (@tail) {
				if ($part =~ /(\d+)$/) {
					$tail += $1;
				}
			}
			
			if (scalar(@maxtail)==1 and $tail<=$maxtail[0]) {
				$tailpass = 1;
			} elsif (scalar(@maxtail)==2 and ($tail/$readlen_after) <= ($maxtail[0]/$maxtail[1])) {
				$tailpass = 1;
			}
		### criterion: tail ###
		
			# output:
			if ($identicalpass and $gappass and $tailpass and $mmpass and $mappingscore_pass and $pe_insert_pass) {
				print "$_\n";
				$confident_mapped_read_count{$line[0]}++;
			}
		
		} # end "if mapped"; unmapped reads will not be outputed
		else { # not mapped
			$unmapped_read_count{$line[0]}++;
		}
	} elsif (/^@/) {
		print "$_\n"; # print headers
	}
}
close IN;

# output mapping report:
&time_print;
my @total_count = keys %total_read_count;
my $total_count = $#total_count + 1;
print STDERR "$file\tTotal reads in the SAM output\t$total_count\n";
my @mapped_count = keys %mapped_read_count;
my $mapped_count = $#mapped_count+1;
print STDERR "$file\tReads could be mapped\t$mapped_count\n";

my @confident_mapped_count = keys %confident_mapped_read_count;
my $confident_mapped_count = $#confident_mapped_count+1;
print STDERR "$file\tPassing criteria reads\t$confident_mapped_count\n";

my @unmapped_count = keys %unmapped_read_count;
my $unmapped_count = $#unmapped_count+1;
print STDERR "$file\tUnmapped reads\t$unmapped_count\n";

# print out the criteria:
print STDERR "#---- Parse criteria -----\n";
print STDERR "#minimum number of identical bases\t$identical\n";
print STDERR "#mismatched value (include INDEL penalty) out of matched bases\t@mismatches\n";
my $indel_penalty_value = INDEL_PENALTY;
print STDERR "#INDEL penalty used to calculate mismatched value\t$indel_penalty_value\n";
print STDERR "#maximum length of tail allowed at each side out of matched bases\t@maxtail\n";
print STDERR "#maximum length of the gap allowed\t$maxgap\n";
print STDERR "#minimum mapping score of each read\t$mappingscore\n";


sub errINF {
	print <<EOF;
Usage: perl samparser.pl -i [SAM file] [Options]
	Options
	--input|i: SAM file
	--identical|e: minimum matched and identical base length, default=30bp
	--mismatches|mm|m: two integers to specify the number of mismatches 
		out of the number of basepairs of the matched region of reads; 
		(matched regions are not identical regions, mismatch and indel could occur)
		e.g., --mm 2 36 represents that <=2 mismatches out of 36 bp
	--tail: the maximum bp allowed at each side, two integers to specify the number of tails
		out of the number of basepairs of the reads, not including "N", 
		e.g., --tail 3 75 represents that <=3 bp tails of 75 bp of reads without "N"
	--gap: if a read is split which is indicated by CIGAR N, the internal gap (bp) allowed, default=5000bp; INDEL does not belong to gap
	--mappingscore: the minimum mapping score, default=40;
	--insert: insert range, e.g., 100 600 (default)
	--keep_chimeric_paired: keep paired reads taht are mapped to different chr or contigs if this is specified (on), default is off
	--help: help information
EOF
	exit;
}

#### subroutines ####
sub compare {
	# input two numbers: 1. to-be checked number 2. bit number
	my $out=0;
	my ($in,$bit) = @_;
	if ($in>=$bit) {
		$out=1;
	}
}

# returns the minimum value from an array of numbers
sub min {
	my @sorted = sort {$a <=> $b} @_;
	return shift(@sorted);
} # End of sub min

# returns the maximum value from an array of numbers
sub max {
	my @sorted = sort {$a <=> $b} @_;
	return pop(@sorted);
} # End of sub max

sub time_print {
	my @weekday = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$year = $year + 1900;
	$mon += 1;
	print STDERR "#$mon/$mday/$year $hour:$min:$sec $weekday[$wday]\n";
}
