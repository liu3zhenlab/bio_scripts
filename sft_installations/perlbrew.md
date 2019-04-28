## Install Perlbrew at Beocat.
**perlbrew** is an admin-free perl installation management tool. 

Previously Perl5.22.0 was installed. The path is ~/perl5/perlbrew/perls/perl-5.22.3/bin/perl. Seems the BioNano hybrid assembly tool uses an older Perl version.

Next is to install Perl 5.18.0.
```
perlbrew install perl-5.18.0 # take a while to install
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

