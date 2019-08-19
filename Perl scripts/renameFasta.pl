#!/usr/bin/env perl

##Append Fasta sequences in a folder with the name of the different files

use strict;
use warnings;

my $dir = $ARGV[0];

opendir (my $dh, $dir);


while (my $file = readdir $dh) {
    next if $file =~ /^\.+/;
	
	my $out = $file;
	my $id = $file;
	$id =~ s/.txt//g;

	$out =~ s/.txt/_rename.txt/;
	open (FILE, "$dir/$file") or die $file;
	open (OUT, ">", "$out") or die "$!\t$out";
	while(<FILE>){
		chomp;
		my $line = $_;
		if($line =~ />/){
			$line =~ s/>/>$id\_/g;
		}
		print OUT $line ."\n";
	}
}