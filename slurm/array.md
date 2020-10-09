## SLURM array

Here is the example to run 10 array jobs.
```
sbatch --array=1-10 code.sh
```
In the *code.sh*, $SLURM_ARRAY_TASK_ID can be used to link with the target files.

### cancel some array jobs
```
# cancel array jobs 3-5 of the array jobid of 1234555
scancel 1234555_[3-5]
```
