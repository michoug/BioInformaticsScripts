#!/usr/bin/perl

use strict;
use warnings;
use File::Slurp;


my ($nrfile, $dir) = @ARGV;
my %hash;

opendir FOLDER, $dir or die "Could not open '$dir' for reading: $!\n";


while (my $file = readdir FOLDER) {
    if($file =~ /xml/){
        my $text = read_file("$dir/$file");
        my @i = split "</GBSeq>", $text;
        pop @i;
        for my $i (@i){
            my $tax = $i;
            my $prod = $i;
            my $locus = $i;

            $locus =~ s/.*<GBSeq_accession-version>(.*)<\/GBSeq_accession-version>.*/$1/sg;
            $tax =~ s/.*<GBSeq_taxonomy>(.*)<\/GBSeq_taxonomy>.*/$1/sg;
            $prod =~ s/.*<GBSeq_definition>(.*)<\/GBSeq_definition>.*/$1/sg;
            next if $locus eq "";
            #print "$locus\t$tax\t$prod\n";
            $hash{$locus} = "$locus\t$tax\t$prod";
        }
        
    }

}

close FOLDER;

open FILE, $nrfile;

while(<FILE>){
    chomp;
    my @line = split /\t/;
    my $results; 
    if (defined $hash{$line[1]}){
        $results = "$hash{$line[1]}";
    }
    else{
        $results = "$line[1]\t\t";
    }

    $line[1] = $results;
    my $final = join "\t", @line ;
    print "$final\n";
}

