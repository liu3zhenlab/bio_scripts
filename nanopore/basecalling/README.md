## Guide to run albacore in Beocat at K-State
### INSTALLATION
1. Download a new version of albacore from Nanopore community. Select the Python3.6 version.
2. Create a virtual environment
```
module load Python/3.6.4-foss-2018a  # the version of Python is subject to change
mkdir ~/virtualenvs
cd ~/virtualenvs
virtualenv python3.6.4 # python3.6.4 can be any name
```
3. install albacore
```
source ~/virtualenvs/python3.6.4/bin/activate
pip3 install <path-to-downloaded_albacore_package>
deactivate
```
### Base calling


