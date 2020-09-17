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

jobid=`printf %04d $jobid`
minid=`expr $jobid \* 1000000 - 1000000 + 1`
maxid=`expr $jobid \* 1000000`

if [ $maxid -gt 510 ] ; then
  maxid=510
fi

if [ $minid -gt $maxid ] ; then
  echo Job partitioning error -- minid=$minid maxid=$maxid.
  exit
fi

if [ -e /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mertrim/kra.4.asm.$jobid.merTrim ]; then
  echo Job previously completed successfully.
  exit
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

$bin/merTrim \
 -b  $minid \
 -e  $maxid \
 -g  /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/kra.4.asm.gkpStore \
 -t  4 \
 -m  22 \
 -mc /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mercounts/kra.4.asm-C-ms22-cm0 \
 -o  /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mertrim/kra.4.asm.$jobid.merTrim.WORKING \
 >   /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mertrim/kra.4.asm.$jobid.err 2>&1 \
&& \
mv /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mertrim/kra.4.asm.$jobid.merTrim.WORKING /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/0-mertrim/kra.4.asm.$jobid.merTrim

exit 0
