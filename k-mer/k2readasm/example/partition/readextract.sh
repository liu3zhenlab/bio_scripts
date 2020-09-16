#!/bin/bash
aid=$SLURM_ARRAY_TASK_ID
perl ../../k2readasm --kmer ../../data/kmertable \
	--r1 partition_${aid}_1.fq --r2 partition_${aid}_2.fq \
	--noasm --prefix partition_${aid}
