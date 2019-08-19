use strict;
use Bib::CrossRef;

my $file = $ARGV[0];
open FILE, $file;
my $n = 1;
while(<FILE>){
	chomp;
	my $line = $_;
	my $ref = Bib::CrossRef->new();
	$ref->parse_text($line);

	my $doi = $ref->doi;
	my $title = $ref->atitle;
	open(TEMP,">", "$n\.ris");
	print TEMP "TI  - $title\nDO  - $doi\n";
	close TEMP;
	print "$line\t$title\n";
	$n++;
}

