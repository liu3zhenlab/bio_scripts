#!/bin/sh

jobid=$SGE_TASK_ID
if [ x$jobid = x -o x$jobid = xundefined -o x$jobid = x0 ]; then
  jobid=$1
fi
if [ x$jobid = x ]; then
  echo Error: I need SGE_TASK_ID set, or a job index on the command line.
  exit 1
fi
if [ $jobid -gt 1 ]; then
  echo Error: Only 1 partitions, you asked for $jobid.
  exit 1
fi

jobid=`printf %03d $jobid`

if [ -e /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/8-consensus/kra.4.asm_$jobid.success ] ; then
  exit 0
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

$bin/ctgcns \
  -g /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/kra.4.asm.gkpStore \
  -t /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/kra.4.asm.tigStore 21 $jobid \
  -P 0 \
 > /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/8-consensus/kra.4.asm_$jobid.err 2>&1 \
&& \
touch /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/8-consensus/kra.4.asm_$jobid.success
exit 0
