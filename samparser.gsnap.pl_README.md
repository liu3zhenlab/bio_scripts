perl samparser.gsnap.pl
=======================
Sanzhen Liu
Kansas State University
12/27/2013

The script is to parse the GSNAP SAM output to have a confident mapping result.
Below is the usage information of this script.

update:
1/3/2014: Add hard clipping parsing criteira to deal with the case that one read was mapped
	to multiple place and just one of them actually pair with other the paired reads if
	considering the position

12/27/2013: remove read pairs that were mapped to different chromosomes

