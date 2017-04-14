#!/usr/bin/perl

use strict;
use warnings;
use 5.018;

my $dir = $ARGV[0];


my %finalhash;
my @finalArray;
my @tempArray;
my $header;
my $number;

opendir(my $dh, $dir);

while(my $file = readdir $dh){
    next unless $file =~ /[^\_]\_{2}r/;
    my $name = $file;
    $name =~ s/\_\_r.*//g;
    open(FILE,"$dir/$file");
    my %temphash;
    while(<FILE>)
    {
        chomp;
        next if /^Query/;
        next if /^DB/;
        next if /^$/;
        #next if /^Subsystem/;
        my @line = split /\t/;

        my $key = "$line[0]\t$line[1]\t$line[2]\t$line[3]";
        if($line[4] =~ /Number of assignments/){
            $line[4] = "$name  Number of assignments";
            $line[5] = "$name  Relative Abundance (\%)"
        }

        #say "$key\t$line[4]\t$line[5]";
        $temphash{$key} .= "$name\t$line[4]\t$line[5]";
    }

    close FILE;

    if (!%finalhash) { 
        %finalhash = %temphash;
    }
    else{

        for my $j (keys %finalhash){
            if(!exists $temphash{$j}){
                $finalhash{$j} .="\t$name\t0\t0";
            }
        }
        for my $i (keys %temphash){
            if(exists $finalhash{$i})
            {
                $finalhash{$i} .= "\t$temphash{$i}";
            }
            else{
                $finalhash{$i} .= "$temphash{$i}";
            }
        }
    }
}

for my $i (sort keys %finalhash){
    unshift @finalArray, "$i\t$finalhash{$i}" if $i =~ /^Subsystem/;
    push @finalArray, "$i\t$finalhash{$i}";
    $header = "$i\t$finalhash{$i}" if $i =~ /^Subsystem/;
}

my @head = split /\t/, $header;
$number = scalar @head;


for (my $k=4; $k < $number; $k+=3){
    if(exists $head[$k]){
        for my $i (@finalArray){
            
            my @line = split /\t/, $i;
            
            #say "$head[$k]\t$line[$k]";
            if(exists $line[$k]){
                $line[$k] = addTabIfNotGood($line[$k],$head[$k]);
                push @tempArray, join("\t",@line);
            }
            else{
                push @tempArray, join("\t",@line);
                push @tempArray, "$head[$k]\t0\t0";
            }
        }
        @finalArray = @tempArray;
        undef @tempArray;
    }
}

for my $i (@finalArray){
    say $i;
}



sub addTabIfNotGood{
    my $i = $_[0];
    my $j = $_[1];
    if($i !~ /$j/){
        $i = "$j\t0\t0\t$i";   
    }
    return "$i";
}