#!/bin/sh

perl='/usr/bin/env perl'

jobid=$SGE_TASK_ID
if [ x$jobid = x -o x$jobid = xundefined -o x$jobid = x0 ]; then
  jobid=$1
fi
if [ x$jobid = x ]; then
  echo Error: I need SGE_TASK_ID set, or a job index on the command line.
  exit 1
fi

bat=`head -n $jobid /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/ovlbat | tail -n 1`
job=`head -n $jobid /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/ovljob | tail -n 1`
opt=`head -n $jobid /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/ovlopt | tail -n 1`
jid=$$

if [ ! -d /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/$bat ]; then
  mkdir /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/$bat
fi

if [ -e /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/$bat/$job.ovb.gz ]; then
  echo Job previously completed successfully.
  exit
fi

if [ x$bat = x ]; then
  echo Error: Job index out of range.
  exit 1
fi

AS_OVL_ERROR_RATE=0.06
AS_CNS_ERROR_RATE=0.06
AS_CGW_ERROR_RATE=0.1
AS_OVERLAP_MIN_LEN=40
AS_READ_MIN_LEN=64
export AS_OVL_ERROR_RATE AS_CNS_ERROR_RATE AS_CGW_ERROR_RATE AS_OVERLAP_MIN_LEN AS_READ_MIN_LEN

syst=`uname -s`
arch=`uname -m`
name=`uname -n`

if [ "$arch" = "x86_64" ] ; then
  arch="amd64"
fi
if [ "$arch" = "Power Macintosh" ] ; then
  arch="ppc"
fi

bin="/homes/liu3zhen/scripts2/k2readasm/$syst-$arch/bin"

$bin/overlapInCore -G --hashbits 22 --hashload 0.75 -t 2 \
  $opt \
  -k 22 \
  -k /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mercounts/kra.4.asm.nmers.obt.fasta \
  -o /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/$bat/$job.ovb.WORKING.gz \
  /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/kra.4.asm.gkpStore \
&& \
mv /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/$bat/$job.ovb.WORKING.gz /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-overlaptrim-overlap/$bat/$job.ovb.gz

exit 0
