#!/usr/bin/perl -w

#unisce i risultati di varie ricerche di ortholuge effettuate tenendo costanti gli ingroup e variando l'outgroup

#uso: perl merge_ortholuge_outwalking.pl -s [file iniziale] -a [file con colonne da aggiungere] -h [true/false]

#acquisire i parametri
my $header="false";
for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-s"){
		$startfile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-a"){
		$addfile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif (($ARGV[$i]) eq "-h"){
		$header = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

#inizializzazione array
my @titles;
my @frame;
my @lspacer;
my @rspacer;

#impostare il valore per head
if ($header eq "true"){
	$n="+2";
}
elsif ($header eq "false"){
	$n="+1";
}
else {
	die ('merge_ortholuge_outwalking.pl: -h può essere solo "true" o "false"\n');
}

#controllare che esistano i file
die ("merge_ortholuge_outwalking.pl: $startfile non trovato\n") if (!-e $startfile);
die ("merge_ortholuge_outwalking.pl: $addfile non trovato\n") if (!-e $addfile);

#ottenere gli an
$a = `tail -n $n $startfile $addfile | cut -f 1 | grep "^==>" -v | sort | uniq | tail -n +2`;
@anlist = split("\n",$a);


#creare gli spaziatori (destro e sinistro) che corrispondono alle colonne degli outgroup
open (Fhi, "<$startfile");
while (<Fhi>){
	chomp;
	my @a = split(/\t/,$_);
	die ("merge_ortholuge_outwalking.pl: startfile $startfile non ha il numero di colonne atteso\n") if ($#a<2);
	for ($i=2;$i<=$#a;$i++){
		push (@lspacer, "-");
	}
	last;
}
close Fhi;


open (Fhi, "<$addfile") or die ("merge_ortholuge_outwalking.pl: $addfile not found\n");
while (<Fhi>){
	chomp;
	my @b = split(/\t/,$_);
	die ("merge_ortholuge_outwalking.pl: addfile $addfile non ha il numero di colonne atteso\n") if ($#b<2);
	for ($i=2;$i<=$#b;$i++){
		push (@rspacer, "-");
	}
	last;
}
close Fhi;

#indicizzare i file - ok tenere
open (Fhi,"<$startfile") or die ("merge_ortholuge_outwalking.pl: $startfile not found\n");
$i=0;
while (<Fhi>){
	chomp;
	my @a = split(/\t/,$_);
	if ($header eq "true" and $i == 0){
		push(@titles,@a[0..$#a]);
		$i=1;
		next;
	}
	$start{$a[0]} = join ("\t", @a[1..$#a]);
}
close Fhi;

open (Fhi,"<$addfile") or die ("merge_ortholuge_outwalking.pl: $addfile not found\n");
$q=0;
while (<Fhi>){
	chomp;
	my @b = split(/\t/,$_);
	if ($header eq "true" and $q == 0){
		push(@titles,@b[2..$#b]);
		$q=1;
		next;
	}
	$add{$b[0]} = join ("\t", @b[1..$#b]);
}
close Fhi;

#unire i file
foreach $in1(@anlist) {
	if ($start{$in1}) {
		@a = split (/\t/,$start{$in1});
	}
	if ($add{$in1}) {
		@b = split (/\t/,$add{$in1});
	}
	
	if ($start{$in1}){
		$in2 = $a[0];
	}
	elsif ($add{$in1}){
		$in2 = $b[0];
	}
	else {
		$in2 = "-";
	}
	
	if ($start{$in1}) {
		@left = @a[1..$#a];
	}
	else {
		@left = @lspacer;
	}
	if ($add{$in1}) {
		@right = @b[1..$#b];
	}
	else {
		@right = @rspacer;
	}
	
	$output{$in1} = join("\t", $in2, @left[0..$#left], @right[0..$#right]);
}

my $firstline=join("\t",@titles[0..$#titles]);
print("$firstline\n") if ($header eq "true");
foreach $an(keys(%output)){
	print("$an\t$output{$an}\n");
}