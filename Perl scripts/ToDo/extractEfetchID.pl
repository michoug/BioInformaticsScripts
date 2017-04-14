#!/usr/bin/perl

## Script that takes an column with NCBI tax id, get the unique values and using the efetch website, get the taxonomy of the sequence

use strict;
use warnings;
use List::MoreUtils qw(uniq);
use LWP::Simple qw(get);
use HTTP::Tiny;

my %hash;
my @ids;
my $n = 1;

while(<>){
    chomp;
    my @line = split /\t/;
    push @ids, $line[3];
    #$hash{$line[2]} = $line[3];
}

#print scalar @ids;

my @Ids2 = uniq @ids;
my @uniqIds = sort @Ids2;
my @remain;
#print scalar @uniqIds;



open(FILE,">", "TableIdTax.txt");

for my $i (@uniqIds){
    my $j = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$i&retmode=xml";
    my $response = HTTP::Tiny->new->get($j);
    if ($response->{success}) {
        my $html = $response->{content};
        $html =~ s/.*<GBSeq_organism>(.*)<\/GBSeq_organism>.*/$1/sg;
        $hash{$i} = $html;
        #print "$i\n";
        print "$i\t$html\t$n\n";
        print FILE "$i\t$html\t$n\n";
        $n++;
        @remain = grep {$_ ne $i} @remain;
        sleep(60) if ($n % 20 == 0) ;
    }
    else{
        print "$i didn\'t work";
        push @remain, $i;
    }
    
}

# for my $i (keys %hash){
#     print "$i\t$hash{$i}\n";
# }

close FILE;

open (FILE2, ">", "idsRemain.txt");

for my $i(@remain){
    print FILE2 "$i\n";
}
close FILE2;