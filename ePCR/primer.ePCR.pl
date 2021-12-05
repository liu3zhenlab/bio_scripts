#!/usr/bin/perl -w
# Sanzhen Liu
# 2/12/2016
# primer.ePCR.pl
# to evaluate targeting uniqueness of primers

my $version = 0.3.0;

# update
# 0.3.0: add the parameter -o

use strict;
use warnings;
use Getopt::Std;
use File::Temp qw/ tempfile tempdir /;

### options:
my $bowtie_parameters = "-p 4 -B 1 -n 1 -y -v 2 -a -l 10 -f --best --quiet --sam-nohead";
my %opts = (p=>"", r=>"", o=>"", m=>50, s=>10000, t=>3, b=>$bowtie_parameters, h=>0);	
getopts('p:r:o:m:s:t:b:h', \%opts);

if (!$opts{h} and ($opts{p} eq "" or $opts{r} eq "")) {
	print STDERR "both -p and -r are requiied";
}

die(qq/
Usage: primer.ePCR.pl [options]
Options:
  -p <file> primer fasta file; required
  -r <path> bowtie index database; required
            If no indexed files exist and the input is a fasta file, bowtie indexing will be performed. 
  -o <file> 2-column separated by tab of pairs of primer names; optional
            ePCR will only report results of primer pairs in the file
  -m <num>  PCR min length ($opts{m})
  -s <num>  PCR max length ($opts{s})
  -t <num>  maximum mismatches, must <=4 ($opts{t})
            the penalty is 2 for the first 3 bases at 3' end 
  -b <str>  bowtie parameters, refer to bowtie-bio.sourceforge.net ($opts{b})
  \n/) if ($opts{h} || $opts{p} eq "" || $opts{r} eq "");


my $primers = $opts{p};
my $ref = $opts{r};
my $ppairs_file = $opts{o} if ($opts{o} ne "");
my $pcr_min_size = $opts{m};
my $pcr_max_size = $opts{s};
my $max_mismatch = $opts{t};
$bowtie_parameters = $opts{b};

##################################
### check availability of bowtie
##################################
&cmd_check("bowtie");
&cmd_check("bowtie-build");

##################################
### parameters used:
##################################
print "# $0 version=$version\n";
print "# primer fasta file is $primers\n";
print "# base name of bowtie index files is $ref\n";
print "# PCR maximum size allowed is $pcr_max_size\n";
print "# Maximum mismatches allowed is $max_mismatch\n";
print "# note the penalty 2 was used for the first 3 bases at 3' end\n"; 

&runreport("Performing alignment");
##################################
### bowtie alignment
##################################
# check bowtie indexed database
my $bowtie_idx_filenum=`realpath $ref*ebwt | wc -l`;
chomp $bowtie_idx_filenum;
if ($bowtie_idx_filenum == 1 and $ref =~ /fa$|fas$|fasta$/) {
	&runreport("No bowtie indexed files, indexing ...");
	`bowtie-build $ref $ref`;
} 

# bowtie alignment
my $aln = File::Temp->new(TEMPLATE => 'tempXXXXX', SUFFIX => '.aln.tmp');
my $cmd = sprintf("%s %s %s %s > %s", "bowtie", $bowtie_parameters, $ref, $primers, $aln);
print "# $cmd\n";
system($cmd);

&runreport("Alignment completed");

# output example
#primer	+	chr3	185878760	GCAGCAGCTGCACCCAGCAGAGG	IIIIIIIIIIIIIIIIIIIIIII	0	14:G>C,19:C>G

##################################
### read alignment
##################################
&runreport("Read primer alignments");
my %entry_record;
open(IN, $aln) || die;
while (<IN>) {
	chomp;
	my @line = split(/\t/, $_);
	my $entry = $line[0];
	my $ori = $line[1];
	my $chr = $line[2];
	my $pos = $line[3];
	my $seq = $line[4];
	my $primer_len = length($seq);
	if ($ori eq "-") {
		$seq = &revcom($seq);
		$pos = $pos + $primer_len - 1;
	}
	
	### determine mismatch number with the consideration of mismatch positions
	my $mismatches = 0;
	if (exists $line[7]) {
		my $var = $line[7];
		my @var = split(",", $var);
		for (@var) {
			my ($var_pos, $var_base) = split(/:/, $_);
			my $var_score = &mismatch_score($var_pos, $seq, $ori);
			$mismatches += $var_score;
		}
	}
	
	if ($mismatches <= $max_mismatch) {
		my $aln_record = $entry."\t".$seq."\t".$mismatches;
		push(@{$entry_record{$chr}{$ori}{$pos}}, $aln_record);
	}
}

##################################
# input primer pairs
##################################
my %input_primer_pair;
if (defined $ppairs_file) {
	open(PP, $ppairs_file) || die;
	while (<PP>) {
		chomp;
		my ($pn1, $pn2) = split(/\t/, $_);
		$input_primer_pair{$pn1.$pn2}++;
		$input_primer_pair{$pn2.$pn1}++;
	}
	close PP;
}

##################################
### primer match
##################################
&runreport("Match primers based on aligned positions");
### print header:
print "Hit\tfPname\tfPrimer\tfMismatch\tfOri\tfChr\tfPos\trPname\trPrimer\trMismatch\trOri\trChr\trPos\tPCRsize\n";
my %hitpairs;
foreach my $eachchr (keys %entry_record) {
	my %chr_hits = %{$entry_record{$eachchr}};
	my %plus = ();
	if (exists $chr_hits{"+"}) {
		%plus = %{$chr_hits{"+"}};
	}
	
	my %minus = ();
	if (exists $chr_hits{"-"}) {
		%minus = %{$chr_hits{"-"}};
	}
	
	my @plus = keys %plus;
	my @minus = keys %minus;
	if ($#plus>=0 and $#minus>=0) { # both plus and minus has hits
		foreach my $plus_pos (keys %plus) {
			foreach my $minus_pos (keys %minus) {	
				my $pcr_len = $minus_pos - $plus_pos + 1;
				if (($pcr_len >= $pcr_min_size) and ($pcr_len <= $pcr_max_size)) {
					my @plus_entries = @{$plus{$plus_pos}};
					my @minus_entries = @{$minus{$minus_pos}};

					foreach my $each_p (@plus_entries) {
						foreach my $each_m (@minus_entries) {
							my $out = "$each_p\t+\t$eachchr\t$plus_pos\t$each_m\t-\t$eachchr\t$minus_pos\t$pcr_len";
							#########################################
							### extract primer names:
							my $each_p_name = $each_p;
							my $each_m_name = $each_m;
							$each_p_name =~ s/\t.*//;
							$each_m_name =~ s/\t.*//;
							my @pm = ($each_p_name, $each_m_name);
							my @ordered_pm = sort {$a cmp $b} @pm;
							my $opm = $ordered_pm[0].$ordered_pm[1];
							##########################################
							push(@{$hitpairs{$opm}}, $out);
						}
					}
				}
			}
		}
	}
}
close IN;

##################################
### output primer pairs
##################################
&runreport("Output primer pairs");
# output searching result:
foreach my $primer_name_comb (sort {$a cmp $b} keys %hitpairs) {	
	if (!%input_primer_pair or $input_primer_pair{$primer_name_comb}) {
		my @pair = @{$hitpairs{$primer_name_comb}};
		if ($#pair < 1) { ### unique hit
			print "unique\t$pair[0]\n";
		} else {
			my $hit_num = $#pair + 1;
			for (my $i=0; $i<$hit_num; $i++) {
				print "multi$hit_num\t$pair[$i]\n";
			}
		}
	}
}

###########################################
# modules
###########################################
# determine penalty for mismatch
sub mismatch_score {
	my ($vp, $in_seq, $in_ori) = @_;
	my $in_seq_len = length($in_seq);
	
	my $vp2end3 = $vp;
	if ($in_ori eq "+") {
		$vp2end3 = $in_seq_len - $vp + 1;
	}
	
	my $mm_score = 1;
	if ($vp2end3 <= 3) { ### penaty for the first 3 bases at 3' ends
		$mm_score = 2;
	}
	return $mm_score;
}

# reverse complementary
sub revcom {
	my $inseq = shift @_; 
	my $revcom = reverse($inseq);
	$revcom =~ tr/AGCTagct/TCGAtcga/;
	return $revcom;
}

# check accessibility to a certain command
sub cmd_check {
	my $cmd=shift;
	my $cmdPath=`which $cmd 2>/dev/null`;
	
	if ($cmdPath eq "") {
		print STDERR "$cmd was not found\n";
		exit;
	}
}

# funtion to report running return
sub runreport {
	my $injob = shift;
	my $dateinfo = `date +'o %Y-%m-%d %H:%M:%S'`;
	print STDERR "$dateinfo";
	print STDERR "  $injob.\n";
}

