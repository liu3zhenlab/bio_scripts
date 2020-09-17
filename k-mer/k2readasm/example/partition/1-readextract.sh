#!/bin/bash
aid=$SLURM_ARRAY_TASK_ID
perl ../../k2readasm --kmer ../../data/kmertable \
	--r1 krasm_${aid}_1.fq --r2 krasm_${aid}_2.fq \
	--noasm --prefix krasm_${aid}
