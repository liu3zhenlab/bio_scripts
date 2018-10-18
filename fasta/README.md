### fasta.reorganiz.pl
A script to rearrange sequences (within a sequence or among sequences) based on a table, which contains six columns:
1. oldcontig
2. start
3. end
4. strand
5. newcontig
6. order

Information provided means that the sequence (*start* to *end*) of the *oldcontig* is to add to the nth part (*order*) of the *newcontig*.

```
perl fasta.cancatenate.pl --fasta <Input Fasta Files> --table <rearrange table>
```
### fasta.size.filter.pl
A Perl script to filter fasta sequences based on the length criteria (min, max, or both).
```
perl fasta.size.filter.pl --min 100 --max 50000 <a_fasta_file>
```
### pattern.search.pl
A script to search matched patterns in a fasta sequence. Here are some example patterns:

"N{100}" - exactly 100 Ns in a row
"A{10,}" - >10 As in a row
"A{5,8}" - 5-8 As in a row
"[AG]CATG[TC]" - NspI restriction site
```
perl pattern.search.pl -I <fasta> -P <pattern>
# more help information
perl pattern.search.pl -h
```
