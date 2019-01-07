#### Installation of BioNano tools

First, download the package:
```
get –N www.bnxinstall.com/access/tools/access.tools.saphyr.tgz
tar -xvf access.tools.saphyr.tgz
```

Second, test to run scripts
```
# pipelineCL
pipeline_dir=/homes/liu3zhen/software/BioNano/tools/pipeline/1.0/RefAligner/1.0
python $pipeline_dir/pipelineCL.py -h

# RefAligner
binary_dir=/homes/liu3zhen/software/BioNano/tools/pipeline/1.0/RefAligner/1.0
$binary_dir/RefAligner -help
```
If RefAligner does not work, try running RefAligner on the subdirectory of "sse" or "avx" (under $binary_dir).

If all look fine, run commands.
