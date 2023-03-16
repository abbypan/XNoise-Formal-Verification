#!/usr/bin/perl
use File::Slurp qw/slurp/;
use Data::Dumper;

my @head = qw/pattern type msg query cont cont_res proved_res/;

open my $fh, '>', 'xnoise.proverif.summary.csv';

my @pv = glob("pv/*.pv");

for my $f (@pv){
    my $log_f = "$f.log";
    print "$f\n$log_f\n";

    my @f_res;

    my @names = split /\./, $f;
    my $pattern = $names[0];
    my $type = $names[2];

    my $pvc = slurp($f); 
    ($pvc) = $pvc=~/query c:principal,.+?\n(.+?event\(RecvEnd\(true\)\)\.)/s;
    my @list = split /\n+/, $pvc;

    for(my $i=0;$i<$#list;$i+=2){
        my $head = $list[$i];
        my $cont = $list[$i+1];
        next if($cont=~/^\s*\(\*/s); 

        my ($msg, $query) = $head=~m#\(\* (.+?): (.+?) \*\)#s;
        $cont=~s/^\s*//s;
        $cont=~s/[;\.]\s*$//s;

        push @f_res, [ $pattern, $type, $msg, $query, $cont ];
    }

    #print Dumper(\@f_res);

    my @v_res;
    my $rc = slurp($log_f);
    ($rc) = $rc=~/Verification summary:\s+(.+?)\n[-]+\n/s;
    my @rclist = split /\n+/, $rc;
    for my $i ( 0 .. $#rclist){
        my ($q, $re) = $rclist[$i]=~m#Query (.+?) (is true|cannot be proved)\.#s;
        push @v_res, [$q, $re]; 
    }
    print "f_res: ", scalar(@f_res), "\n";
    print "v_res: ", scalar(@v_res), "\n";
   
    for my $i (0 .. $#f_res){
        print $fh join(";", @{$f_res[$i]}, @{$v_res[$i]}), "\n";
    }
}
close $fh;
