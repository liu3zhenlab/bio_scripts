#!/bin/bash

scriptPath=../..
kmertable=../../data/kmertable
fq1=../../data/read1.fq
fq2=../../data/read2.fq
num=2
prefix=partition
finalprefix=kreads # different with $prefix to avoid removal during the cleanup step

# step 1: split fastq data
perl $scriptPath/utils/fastq.split.pl --fq1 $fq1 --fq2 $fq2 --npart $num --prefix $prefix

# step 2: generate a univeral running code;
resh=readextract.sh
echo "#!/bin/bash" > $resh
echo "aid=\$SLURM_ARRAY_TASK_ID" >> $resh
echo "perl ${scriptPath}/k2readasm --kmer ${kmertable} \\" >> $resh
echo "	--r1 ${prefix}_\${aid}_1.fq --r2 ${prefix}_\${aid}_2.fq \\" >> $resh
echo "	--noasm --prefix ${prefix}_\${aid}" >> $resh

# step 3: run extraction in a batch mode
jidInfo=$(sbatch \
--array=1-$num \
--time=1-00:00:00 \
--cpus-per-task=1 \
--mem-per-cpu=8G \
$resh)

echo $jidInfo
jid=`echo $jidInfo | sed 's/.* //g'`  # to only keep job ID

# step 4: merging and cleanup
mergesh=merge.sh
echo "#!/bin/bash" > $mergesh
echo "cat ${prefix}_*.3.reads_1.fq > ${finalprefix}.3.reads_1.fq" >> $mergesh
echo "cat ${prefix}_*.3.reads_2.fq > ${finalprefix}.3.reads_2.fq" >> $mergesh
echo "rm ${prefix}*" >> $mergesh

sbatch --dependency=afterany:$jid $mergesh

