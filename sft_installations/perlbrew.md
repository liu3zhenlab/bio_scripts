## Install Perlbrew at Beocat.
**perlbrew** is an admin-free perl installation management tool. 

Previously Perl5.22.0 was installed. The path is ~/perl5/perlbrew/perls/perl-5.22.3/bin/perl. Seems the BioNano hybrid assembly tool uses and an older Perl version.
```
perlbree install perl-5.18.0 # take a while to install
```

```
perlbrew exec perl xxx.pl
```
It actually tested all the installed Perlbrew versions and found out which one(s) might work. For the script, hybridScaffold.pl, I tested. Seemed the versio. 5.16.3 worked.


```
perlbrew switch perl-5.16.3
```

