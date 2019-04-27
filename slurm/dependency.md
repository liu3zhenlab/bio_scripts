## job dependency

### Job step2 will be run after step1 is completed.
```
jidInfo=$(sbatch step1.sh)
echo $jidInfo
jid=`echo $jidInfo | sed 's/.* //g'`  # to only keep job ID
sbatch --dependency=afterany:$jid step2.sh
```


