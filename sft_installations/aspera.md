### aspera installation in Beocat

1. download "aspera connect" at https://downloads.asperasoft.com
2. untar the download file
3. run (for example)
```
sh ibm-aspera-connect-3.9.1.171801-linux-g2.12-64.sh
```
Note that the command **ascp** are located at /homes/liu3zhen/.aspera/connect/bin.
4. set the path
5. run ascp

### SRA data submission example
ascp -d <directory containing submitted files> ...
