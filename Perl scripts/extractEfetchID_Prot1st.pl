#!/usr/bin/perl

use strict;
use warnings;
use List::MoreUtils qw(uniq);
use LWP::Simple qw(get);
use HTTP::Tiny;
use Bio::DB::EUtilities;
use Bio::SeqIO;

my %hash;
my @ids;
my $n = 1;

while(<>){
    chomp;
    my @line = split /\t/;
    if($line[1] =~ "\|"){
        my @lol = split "\\|", $line[1];
        #print "$lol[3]\n";
        push @ids, $lol[3];
    }
    else{
        push @ids, $line[1];
    }
    
}

print scalar @ids;



my @Ids2 = uniq @ids;
my @uniqIds = sort @Ids2;


while ( my @smallchunks = splice @uniqIds, 0, 200 ) {

	my $factory = Bio::DB::EUtilities->new(-eutil => 'efetch',
                                       -db      => 'protein',
                                       -retmode=> 'xml',
                                       -email   => 'mymail@foo.bar',
                                       -id      => \@smallchunks);

	my $file = "Response_$n.xml";
	$factory->get_Response(-file => $file);
	$n++;
}
