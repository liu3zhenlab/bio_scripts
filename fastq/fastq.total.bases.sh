fq=$1;
seqtk comp $fq | awk '{total += $2} END {print "Total bases:", total}'

