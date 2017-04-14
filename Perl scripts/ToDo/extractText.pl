#!/usr/bin/perl

use strict;
use warnings;

my $folder = $ARGV[0];

opendir my $dir, "$folder" or die "Cannot open directory: $!";
my @files = readdir $dir;


for my $file (@files){
    if($file =~ /fas/){
        
        open (FILE, "$folder/$file");
        my $lines = do { local $/; <FILE> };
        # #my $lines = <FILE>;
        # #my $id = $lines;
        # #$id =~ s//$1/g;

        $lines =~ s/.*(>.*?\n).*BEGIN_CONSENSUS_SEQUENCE\n(.*\n)END_CONSENSUS_SEQUENCE.*/$1$2/gs ;
        my $file2 = $file;
        $file2 =~ s/\.fas/_Final.fas/;

        open(OUTPUT,">", "$folder/$file2");
        print OUTPUT "$lines";
        close OUTPUT;



    }

}

closedir $dir;
