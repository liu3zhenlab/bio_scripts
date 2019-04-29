## Install Perlbrew at Beocat.
**perlbrew** is an admin-free perl installation management tool. 

First, install perlbrew and install Perl 5.22.3.
```
curl -L http://install.perlbrew.pl | bash
#Make sure that ~/.bash_profile exists
if [ ! -f ~/.bash_profile ]; then cp /etc/skel/.bash_profile 
~/.bash_profile; fi
echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.bash_profile
source ~/.bash_profile
perlbrew install -f -n -D usethreads perl-5.22.3
perlbrew switch perl-5.22.3
```
Perl 5.22.3 is now installed. The path is ~/perl5/perlbrew/perls/perl-5.22.3/bin/perl. If an older Perl version is needed, the older version can be added..

Next let us install Perl 5.18.0 and Perl 5.16.3.
```
perlbrew install perl-5.18.0 # take a while to install
perlbrew install perl-5.16.3
```

Run the following script to test all installed versions.
```
perlbrew exec perl xxx.pl
```
The test indicated that, for the script I tested, the version 5.16.3 worked.

Now switch the version to Perl 5.16.3, which can be switched to a newer version later.
```
perlbrew switch perl-5.16.3
```

