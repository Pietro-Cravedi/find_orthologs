#!/usr/bin/perl -w

#uso perl add_names.pl -m [replace/add] -i [file] -t [tabella di corrispondenza scaricata dal sito NCBI] -af [colonna con gli AN] -nf [colonna con i nomi di organismo]
#aggiunge i nomi degli organismi sopra le intestazioni di colonna (se sono AN)

$mode="add";

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-i"){
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("add_names.pl: $infile non trovato\n") if (!-e $infile);
	}
	elsif ($ARGV[$i] eq "-t"){
		$table = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("add_names.pl: $table non trovato\n") if (!-e $table);
	}
	elsif ($ARGV[$i] eq "-af"){
		$accfield = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-nf"){
		$namfield = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-m"){
		$mode = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("add_names.pl: -m può essere solo replace o add\n") if (not(($mode =~ "replace") or ($mode =~ "add"))); 
	}
}

die ("add_names.pl: Argomento -i non fornito\n") if (not $infile);
die ("add_names.pl: Argomento -t non fornito\n") if (not $table);
die ("add_names.pl: Argomento -af non fornito\n") if (not $accfield);
die ("add_names.pl: Argomento -nf non fornito\n") if (not $namfield);


#indicizzare la tabella - acc => nome
open (Fhi,"<$table");
while (<Fhi>){
	my @line = split(/\t/,$_);
	my $name = $line[$namfield-1];
	my $acc = $line[$accfield-1];
	$acc =~ s/\.\d//g;
	$table{$acc}=$name;
}
close Fhi;

#prendere la prima riga del file
open (Fhi, "<$infile");
while (<Fhi>){
	chomp;
	$fline = $_;
	last;
}
close Fhi;

my @out;
my @line = split(/\t/, $fline);

foreach $an(@line){
	push (@out, $table{$an});
}

print (join("\t",@out[0..$#out]),"\n");
($mode =~ "replace") ? $rest=`tail -n +2 $infile` : $rest=`cat $infile`;
print "$rest\n";