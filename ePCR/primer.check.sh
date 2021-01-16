#!/bin/bash
pfas=primer.fas
ref=/homes/liu3zhen/references/B73Ref4/bowtie/B73Ref4
prefix=primer.onRef
perl primer.ePCR.pl -p $pfas -r $ref 1>${prefix}.txt 2>${prefix}.log

