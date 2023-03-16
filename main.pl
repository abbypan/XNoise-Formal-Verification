#!/usr/bin/perl

my @files = glob("pv/*.pv");

for my $f (@files){
    print `date`;
    print "$f\n";
    system(qq[proverif "$f" | tee "$f.log"]);
}
