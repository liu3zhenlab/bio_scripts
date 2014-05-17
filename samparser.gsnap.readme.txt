perl samparser.gsnap.pl
=======================
Sanzhen Liu
Kansas State University
12/27/2013

The script is to parse the GSNAP SAM output to have a confident mapping result.
Below is the usage information of this script.

to get help information:
perl sampparser.gsnap.pl --help

update:
o 1/3/2014:
	Add hard clipping parsing criteira to deal with the case that one read was mapped
	to multiple places and just one of them actually pair with other the paired reads if
	considering the position. Also a parameter "readlen" was added in order to make
	judgement for hard clipped reads.

o 12/27/2013: 
	Remove read pairs that were mapped to different chromosomes

o 5/12/2013
	Repair a bug - add "\" to @insert at line 31 

