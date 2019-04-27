## SLURM array

Here is the example to run 10 array jobs.
```
sbatch --array=1-10 code.sh
```
In the *code.sh*, $SLURM_ARRAY_TASK_ID can be used to link with the target files.
