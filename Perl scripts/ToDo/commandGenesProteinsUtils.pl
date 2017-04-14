#!/usr/bin/perl

## This script uses Bio::DB::EUtilities of BioPerl and ncbi to get the protein sequences from a gene id.

use Bio::DB::EUtilities;
use Bio::SeqIO;
use IO::String;
use strict;
use warnings;

my $id = "pcag[PREF]";

while(<>)
{
    
}

#print \$id;
my $factory = Bio::DB::EUtilities->new(-eutil => 'esearch',
                                       -db     => 'gene',
                                       -term   => $id,
                                       -email  => 'mymail@foo.bar');

print "Query: ",$factory->get_query_translation,"\n";

$id =~ s/\[PREF\]//g;


my @ids = $factory->get_ids;

my $factory1 = Bio::DB::EUtilities->new(-eutil => 'elink',
                                       -email  => 'mymail@foo.bar',
                                       -db     => 'protein',
                                       -dbfrom => 'gene',
                                       -id     => \@ids);
my @prots;

while (my $ds = $factory1->next_LinkSet) {
    
    if($ds->get_link_name eq "gene_protein_refseq"){
        #print "Gene IDs: ",join(',',$ds->get_submitted_ids),"\n";
        
        @prots = $ds->get_ids;
    }
}

my $factory2 = Bio::DB::EUtilities->new(-eutil => 'efetch',
                                       -db      => 'protein',
                                       -rettype => 'fasta',
                                       -retmode => 'text',
                                       -email   => 'mymail@foo.bar',
                                       -id      => \@prots);

my $seq = $factory2->get_Response->content;

my $seqfh = IO::String->new($seq); 

#open($seqfh, "<", $seq) or die;

my $seqin = Bio::SeqIO->new(-fh => $seqfh,
                             -format => 'fasta');

while (my $seq = $seqin->next_seq) {
    
   print ">$id"."_".$seq->id."\n".$seq->seq."\n";
}

