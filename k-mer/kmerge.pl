#!/usr/bin/perl -w
# ===============================================================
# kmerge.pl
# Sanzhen Liu
# 5/10/2019 update
# ===============================================================

use strict;
use warnings;
use File::Temp;
use Getopt::Long;

my $version = "v0.1.0";

sub prompt {
	print <<EOF;
	usage: perl $0 <query> <target> [options]
	version: $version
	<query> query kmer file: 1 or multiple columns with Kmer at the 1st column; the file contains header
	<target> target kmer file; 1 or multiple columns with Kmer at the 1st column; the file contains header
	
	-options-
	  --qall: the output includes all query columns; default is only 1st column if --qall is not specified
	  --tall: the output includes all target columns; default is only 1st column if --tall is not specified
	  --intersect: only the overlapping kmers are kept; default is to merge all to have a union set
	  --missingchar: missing character used to fill in missing data; default=0
	  --splitlevel: splitlevel for original kmer data file (integer 2-4); default=3 (4^3 = 64 subfiles)
	  --help: help information
EOF
exit;
}

my ($qall, $tall, $intersect, $mvalue, $splitlevel, $help);
&GetOptions("qall" => \$qall,
            "tall" => \$tall,
            "intersect|i" => \$intersect,
			"missingchar|m=s" => \$mvalue,
			"splitlevel|s=i" => \$splitlevel,
			"help|h" => \$help);

&prompt if ($help || $#ARGV < 1);
$mvalue = 0 if (!defined $mvalue);
if (!defined $splitlevel) {
	$splitlevel = 3;
} else {
	if ($splitlevel < 2 or $splitlevel > 4) {
		print "ERROR: only 2-4 can be specified for --splitlevel.\n";
		&prompt;
	}
}

my $kmer01 = $ARGV[0];
my $kmer02 = $ARGV[1];

###################################################
### print header:
my $header01;
chomp($header01 = `head $kmer01 -n 1`);
my $header02;
chomp($header02 = `head $kmer02 -n 1`);
my @header01 = split(/\t/, $header01);
my $ncol01 = $#header01;
my @header02 = split(/\t/, $header02);
my $ncol02 = $#header02;

# query header
if ($qall) {
	my $header01_add = join("\t", @header01[0..$ncol01]);
	print "$header01_add";
} else {
	print "$header01[0]";
}

# target header
if ($tall) {
	my $header02_add = join("\t", @header02[1..$ncol02]);
	print "\t$header02_add\n";
} else {
	print "\n";
}

# missing values
my $missing_value01 = $mvalue;
if ($ncol01 > 1) { 
	for (my $i = 2; $i <= $ncol01; $i++) {
		$missing_value01 .= "\t$mvalue";	
	}
}

my $missing_value02 = $mvalue;
if ($ncol02 > 1) {
	for (my $i = 2; $i <= $ncol02; $i++) {
		$missing_value02 .= "\t$mvalue";
	}
}
###################################################

###################################################
### divide a large file into small pieces for efficient merging
###################################################
my @nt = ("A", "T", "C", "G");
my @indexnt = @nt;
my (@newindex, %kmerfiles, $fh01in, $fh02in);
for (my $i = 1; $i < $splitlevel; $i++) {
	foreach my $nt1 (@indexnt) {
		if (!exists $kmerfiles{1}{$nt1}) {
			$fh01in = $kmer01;
		} else {
			$fh01in = $kmerfiles{1}{$nt1};
		}

		if (!exists $kmerfiles{2}{$nt1}) {
			$fh02in = $kmer02;
		} else {
			$fh02in = $kmerfiles{2}{$nt1};
		}

		my $fh01out = File::Temp->new(SUFFIX => '.kmertmp');
		system(sprintf("%s%s%s%s%s%s", "grep \"\^", $nt1, "\" ", $fh01in, " > ", $fh01out));
		
		my $fh02out = File::Temp->new(SUFFIX => '.kmertmp');
		system(sprintf("%s%s%s%s%s%s", "grep \"\^", $nt1, "\" ", $fh02in, " > ", $fh02out));


		foreach my $nt2 (@nt) {
			my $comb = $nt1.$nt2;
			#print STDERR "\@ $comb\n";
			my $fh01out2 = File::Temp->new(SUFFIX => '.kmertmp');
			system(sprintf("%s%s%s%s%s%s", "grep \"\^", $comb, "\" ", $fh01out, " > ", $fh01out2));
			$kmerfiles{1}{$comb} = $fh01out2;
			
			my $fh02out2 = File::Temp->new(SUFFIX => '.kmertmp');
			system(sprintf("%s%s%s%s%s%s", "grep \"\^", $comb, "\" ", $fh02out, " > ", $fh02out2));
			$kmerfiles{2}{$comb} = $fh02out2;
			
			push(@newindex, $comb);
		}
	}
	@indexnt = @newindex;
	@newindex = ();
}


foreach (@indexnt) {
# merge two sets of kmer counts
	my $infile01 = $kmerfiles{1}{$_};
	my @k1 = `grep $_ $infile01`;
	my $infile02 = $kmerfiles{2}{$_};
	my @k2 = `grep $_ $infile02`;
	&merge(\@k1, \@k2);
}


sub merge {
	my ($inkm01, $inkm02) = @_;
	my @km01 = @{$inkm01};
	my @km02 = @{$inkm02};
	my %kmer_hash01 = ();
	my %kmer_hash02 = ();

	foreach (@km01) {
		chomp;
		my @kma = split(/\t/, $_);
		my $km = $kma[0];
		if ($qall) {
			my $kmac = join("\t", @kma[1..$#kma]);
			$kmer_hash01{$km} = $kmac;
		} else {
			$kmer_hash01{$km}++;
		}
	}

	### adding data only contain two columns:
	my $kmbc;
	foreach (@km02) {
		chomp;
		my @kmb = split(/\t/, $_);
		my $km = $kmb[0];
		if ($tall) {
			$kmbc = join("\t", @kmb[1..$#kmb]);
		} else {
			$kmbc = $kmer_hash02{$km}++;
		}

		if (exists $kmer_hash01{$km}) {
			$kmer_hash02{$km} = $kmbc;
		} elsif (!$intersect) {
			$kmer_hash01{$km} = $missing_value01;
			$kmer_hash02{$km} = $kmbc;
		}
	}
	
	### output:
	foreach my $eachkmer (sort {$a cmp $b} keys %kmer_hash01) {
		if (exists $kmer_hash02{$eachkmer}) {
			print "$eachkmer";
			print "\t$kmer_hash01{$eachkmer}" if $qall;
			print "\t$kmer_hash02{$eachkmer}" if $tall;
			print "\n";
		} elsif (!$intersect) {
			print "$eachkmer";
			print "\t$kmer_hash01{$eachkmer}" if $qall;
			print "\t$missing_value02" if $tall;
			print "\n";
		}
	}
}
###################################################

