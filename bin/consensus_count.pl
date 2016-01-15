#!/usr/bin/perl -w

#da usare dopo aver unito tutti i risultati di outgroup_walking.sh per valutare un consenso
#uso perl consensus_count.pl -f [file] -h [true/false]

my %file;
my $header="false";

#prendere i parametri
for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-f"){
		$infile = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-h"){
		$header = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

die ("consensus_count.pl: -h può essere solo true o false\n") if (not(($header eq "true") or ($header eq "false")));

#prendere le intestazioni
if ($header eq "true"){
	open (Fhi,"<$infile") or die ("consensus_count.pl: $infile not found\n");
	while (<Fhi>){
		$titles=$_;
		last;
	}
	close Fhi;
}

open (Fhi,"<$infile") or die ("consensus_count.pl: $infile not found\n");
$q=0;
while (<Fhi>){
	chomp;
	if ($header eq "true" and $q==0){
		$q=1;
		next;
	}
	my @line = split (/\t/,$_);
	$file{$line[0]} = join ("\t", @line[1..$#line]);
	my @counter = @line[2..$#line];
	my $i = 0;
	for $_(@counter){
		$i++ if (/\w\w_\d+/);
	}
	$file{$line[0]} = "$file{$line[0]}\t$i";
}
close Fhi;

print ($titles) if ($titles);
foreach $k(keys(%file)){
	print "$k\t$file{$k}\n";
}