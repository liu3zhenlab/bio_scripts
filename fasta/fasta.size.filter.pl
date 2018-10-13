#!/usr/bin/perl -w
#
# ====================================================================================================
# File: fasta.size.filter.pl
# Author: Sanzhen Liu
# Date: 10/3/2013
# ====================================================================================================

use strict;
use warnings;
use Getopt::Long;

my $seq;
my %seq_size;
my $seq_name;
my $size;
my $min;
my $max;; 
my $total;
my $count;
my $help;

sub prompt {
	print <<EOF;
	Usage: perl fasta.size.filter.pl <Input Fasta File> [options]
	Count the size for each fasta sequence and filter sequences based on the specified criteria.
	--min: minimum length
	--max: maximum length
	--help 
EOF
exit;
}
# read the parameters:
&GetOptions("min=i" => \$min, "max=i" => \$max, "help" => \$help) || &prompt;

if ($help) { &prompt; }
$min = defined $min ? $min : 0;
my $inf = (~0)**(~0);
$max = defined $max ? $max : $inf;
#print $max;
open(IN, $ARGV[0]) || die "The input fasta file cannot be opened.";

# Read all sequence (name and size) into hash;
while (<IN>) {
	$_ =~ s/\R//g;
	chomp;
	if (/^>(.+)/) {
      if (defined $seq_name) {
         if ($size >= $min and $size <= $max) {
		 	print ">$seq_name\n$seq\n";
		 }
      }
      $seq_name = $1;
      $seq = "";
	  $size = 0;
	  $count++;
	}
    else {
      $size += length($_);
	  $seq .= $_;
    }
}
# last element:
if ($size >= $min and $size <= $max) {
	print ">$seq_name\n$seq\n";
}
close IN;

