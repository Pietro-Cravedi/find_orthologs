#!/usr/bin/perl -w

#unisce i risultati dell'ingroup walking
#i file devono essere paddati

#uso: perl merge_ortholuge_inwalking.pl -s [file iniziale] -a [file con colonne da aggiungere] -h [true/false]

my $header="false";
for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-s"){
		$startfile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-a"){
		$addfile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-h"){
		$header = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("merge_ortholuge_inwalking.pl: -h can only be true or false\n") if (not($header eq "true") or ($header eq "false"));

#inizializzare array ed hash
my %start;
my %add;
my @out;
my @titles;

#indicizzare $startfile
open (Fhi,"<$startfile") or die ("merge_ortholuge_inwalking.pl: $startfile not found\n");
$i=0;
while (<Fhi>){
	chomp;
	my @line = split(/\t/,$_);
	if ($header eq "true" and $i == 0){
		push(@titles,@line[0..$#line]);
		$i=1;
		next;
	}
	$start{$line[0]} = join("\t", @line[1..$#line]);
}
close Fhi;

#indicizzare $addfile
open (Fhi,"<$addfile") or die ("merge_ortholuge_inwalking.pl: $addfile not found\n");
$q=0;
while (<Fhi>){
	chomp;
	my @line = split(/\t/,$_);
	if ($header eq "true" and $q == 0){
		push(@titles,@line[1..$#line]);
		$q=1;
		next;
	}
	$add{$line[0]} = join("\t", @line[1..$#line]);
}
close Fhi;

my $firstline=join("\t",@titles[0..$#titles]);
foreach $k(keys(%start)){
	push (@out, "$k\t$start{$k}\t$add{$k}\n");
}

print("$firstline\n");
print @out;