GATK4 with multiple cpus in Slurm system
==============
The script is designed for run GATK HaplotypeCaller with multiple CPUs in parellel. 

Basic script for SNP calling:
```
ref=<fasta>
bamlist=<path to BAM files>
outbase=example
perl ../gatk.sbatch.pl --outbase $outbase \
  --bampaths $bamlist \
  --ref $ref \
```


**List of parameters**
Usage: perl gatk.sbatch.pl --ref <fasta> --bampaths <path-to-bam> --outbase <base of outputs> [options]

Options:
--outbase <base name>: base for all outputs, required
--ref <ref fasta file>: path to the reference fasta file with suffix of "fa", "fas", or "fasta
       directory containing this file also has its indexed files: .dict and .fai
--bampaths <paths containing BAM files>: paths to directories containing bam files; required
--mem <memory>: memory per thread/cpu; default=24G
--time <time>: running time for each array subjob; default=0-23:59:59
--threads <num>: running thread per job; default=1
--selectseq <file containing names of targeted sequences>: equence names for variant discovery;
  one per line. All sequences will be used if no file is provided.
--java <java module>: Java module; default=Java/1.8.0_192
--maxlen <max length>: maximal interval length of each job to call variants; default=2000000
--checkscript: only produce scripts/files and no SBATCH run
--help: helping information
