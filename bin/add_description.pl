#!/usr/bin/perl -w

#uso perl add_description.pl -o [file ortholuge] -g [genoma] -f [colonna del file (1..n)] -h [true/false]

my %descr;
my %ort;
my $header="false";

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-o"){
		$ortfile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-g"){
		$genome = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-f"){
		$field = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-h"){
		$header = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

die ("add_description.pl: Argomento -o non fornito\n") if (not $ortfile);
die ("add_description.pl: Argomento -g non fornito\n") if (not $genome);
die ("add_description.pl: Argomento -f non fornito\n") if (not $field);
die ("add_description.pl: -h può essere solo true o false\n") if (not(($header eq "true") or ($header eq "false")));

#recuperare le intestazioni
if ($header eq "true"){
	open (Fhi,"<$ortfile") or die ("add_description.pl: $ortfile non trovato\n");
	while (<Fhi>){
		$titles=$_;
		last;
	}
	close Fhi;
}

#reperirie ed indicizzare descrizioni
open (Fhi,"<$genome") or die ("add_description.pl: $genome non trovato\n");
$/=">";
$cont=0;
while (<Fhi>){
	$cont++;
	($cont ==1 ) && next;
	chomp;
	my $seq = $_;
	/(\wP_\d+).\d\|/;
	my $an=$1;
	my @a = split (/\n/, $seq);
	my @b = split (/\s/, $a[0]);
	my $c = join (" ", @b[1..$#b]);
	my @d = split (/\[/,$c);
	$descr{$an}=$d[0];
}
$/="\n";
close Fhi;

#indicizzare file ortholuge
open (Fhi,"<$ortfile") or die ("add_description.pl: $ortfile non trovato\n");
my $i=0;
while (<Fhi>){
	if ($header eq "true" and $i==0){
		$i=1;
		next;
	}
	chomp;
	my $l=$_;
	my @line = split (/\t/, $l);
	my $acc = $line[$field-1];
	$ort{$acc}=$l;
}
close Fhi;

print ($titles) if ($titles);
foreach $k(keys %ort){
	print "$ort{$k}\t$descr{$k}\n";
}