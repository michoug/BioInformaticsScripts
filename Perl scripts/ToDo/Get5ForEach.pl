#!/usr/bin/perl

use strict;
use warnings;

my $n = 0;
my $id;

while(<>){
    chomp;
    my @line = split /\t/;
    if($n == 0){
        $id = $line[0];
        print "$_\n";
        $n++;

    }
    elsif($n < 5){
        print "$_\n";
        $n++;
    }
    else{
        if($id eq $line[0])
        {
            next;
        }
        else{
            $n= 0;
        }

    }
    #print "$n\n";

}