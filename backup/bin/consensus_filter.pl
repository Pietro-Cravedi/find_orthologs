#!/usr/bin/perl -w

#uso: perl consensus_filter.pl -f [file] -t [soglia] -h [true/false]

my $header="false";
my $nofilt="false";

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-file"){
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-threshold"){
		$threshold = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-header"){
		$header = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-nofilt"){
		$nofilt = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

my %out;

die ("consensus_filter.pl: -header può essere solo true o false\n") if (not(($header eq "true") or ($header eq "false")));
die ("consensus_filter.pl: -nofilt può essere solo true o false\n") if (not(($nofilt eq "true") or ($nofilt eq "false")));

#prendere le intestazioni
if ($header eq "true"){
	open (Fhi,"<$infile") or die ("consensus_filter.pl: $infile not found\n");
	while (<Fhi>){
		$titles=$_;
		last;
	}
	close Fhi;
}

open (Fhi,"<$infile") or die ("consensus_filter.pl: $infile not found\n");
$i=0;
while (<Fhi>){
	chomp;
	if ($header eq "true" and $i==0){
		$i=1;
		next;
	}
	my @line = split(/\t/, $_);
	my $acc = $line[0];
	my $cons = $line[$#line];
	if ($nofilt eq "true"){
		$line[1]="brh_$line[1]" if ($cons == 1);
	}
	if ($cons>=$threshold){
		$out{$acc}=join("\t",@line[1..$#line-1]);
	}
}
close Fhi;

print($titles) if ($titles);
foreach $k(keys(%out)){
	print "$k\t$out{$k}\n";
}