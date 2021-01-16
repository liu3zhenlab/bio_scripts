#!/bin/bash
pfas=primers.fas
ref=refdb
prefix=out
perl primer.ePCR.pl -p $pfas -r $ref 1>${prefix}.txt 2>${prefix}.log

