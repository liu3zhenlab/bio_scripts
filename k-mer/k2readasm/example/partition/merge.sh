#!/bin/bash
cat partition_*.3.reads_1.fq > kreads.3.reads_1.fq
cat partition_*.3.reads_2.fq > kreads.3.reads_2.fq
rm partition*
