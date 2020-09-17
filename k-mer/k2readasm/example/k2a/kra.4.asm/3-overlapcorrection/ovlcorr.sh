jobid=$SGE_TASK_ID
if [ x$jobid = x -o x$jobid = xundefined -o x$jobid = x0 ]; then
  jobid=$1
fi
if [ x$jobid = x ]; then
  echo Error: I need SGE_TASK_ID set, or a job index on the command line.
  exit 1
fi

if [ $jobid -gt 1 ] ; then
  exit
fi

jobid=`printf %04d $jobid`
frgBeg=`expr $jobid \* 200000 - 200000 + 1`
frgEnd=`expr $jobid \* 200000`
if [ $frgEnd -ge 510 ] ; then
  frgEnd=510
fi
frgBeg=`printf %08d $frgBeg`
frgEnd=`printf %08d $frgEnd`

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

if [ ! -e /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/3-overlapcorrection/$jobid.erate ] ; then
  $bin/correct-olaps \
    -S /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/kra.4.asm.ovlStore \
    -e /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/3-overlapcorrection/$jobid.erate.WORKING \
    /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/kra.4.asm.gkpStore \
    /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/3-overlapcorrection/kra.4.asm.frgcorr \
    $frgBeg $frgEnd \
  &&  \
  mv /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/3-overlapcorrection/$jobid.erate.WORKING /homes/liu3zhen/scripts2/k2readasm/example/k2a/kra.4.asm/3-overlapcorrection/$jobid.erate
fi
