### InkScape

#### software downloading
```
wget https://code.launchpad.net/~inkscape.dev/+archive/ubuntu/stable/+sourcefiles/inkscape/0.92.4+68~ubuntu19.04.1/inkscape_0.92.4+68~ubuntu19.04.1.tar.xz
```

#### Notes:
I run the following script but not sure why these scripts are needed.
```
sudo add-apt-repository ppa:inkscape.dev/stable
sudo apt-get update
```

#### installation of dependancies
```
sudo apt-get install dh-autoreconf
sudo apt-get install intltool
sudo apt-get install liblcms2-dev
sudo apt-get install libcairomm-1.0-dev
sudo apt-get install libglibmm-2.4-dev
sudo apt-get install libsigc++-2.0-dev
sudo apt-get install libgsl-dev 
sudo apt-get install libxslt1-dev
sudo apt-get install libpango1.0-dev
sudo apt-get install libgc-dev
sudo apt-get install gtk2.0
sudo apt-get install libgtkmm-2.4-dev
sudo apt-get install libboost-dev
sudo apt-get install libpopt-dev 
sudo apt-get install imagemagick
```

#### Still InkScape did not work.
```
./configure # successful
make # error occured
make check # list some errors
sudo make install # not run yet
```
