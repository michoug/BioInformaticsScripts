#!/usr/bin/perl

use strict;
use warnings;
use List::MoreUtils qw(uniq);

#From a orthoVenn cluster file, extract all the ones that are the same as the ones 
#in the command line and only these ones


my @options = @ARGV;

my $file = shift @options;

open(FILE, $file);
while(my $line = <FILE>){

    chomp $line;
    my $names = $line;
    $names =~ s/\|.*?\t/\t/g;
    $names =~ s/\|.*?$//g;

    my @splitNames = split /\t/, $names;
    my @uniqNames = uniq @splitNames; # get uniq names



    for my $i (@options){
        @uniqNames = grep {!/$i/} @uniqNames; #remove the names that are of interest
    }
    
    next if @uniqNames; # Next if other names that are not of interest

    for my $i (@options){
        print "$line\n" if  $line =~ /$i/;
    }
}

close FILE;