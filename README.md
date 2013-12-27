scripts
=======
Sanzhen Liu
Kansas State University
12/27/2013

The script is to parse the GSNAP SAM output to have a confident mapping result.
Below is the usage information of this script.

-------------------------------------------------------------------------------------------
Usage: perl samparser.gsnap.pl -i [SAM file] [Options]
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
	--gap: if a read is split, the internal gap (bp) allowed, default=5000bp
	--maxloci: the maximum mapping locations, default=1;
	--help: help information
-------------------------------------------------------------------------------------------
