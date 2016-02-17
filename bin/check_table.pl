#!/usr/bin/perl -w

$outfile="./log.txt";
$type="new";

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-table"){
		$table = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-list"){
		$infile = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-out"){
		$outfile = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-type"){
		$type = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("check_table.pl: -table non specificato\n") if (!$table);
die ("check_table.pl: -list non specificato\n") if (!$infile);
die ("check_table.pl: -out non specificato\n") if (!$outfile);

my @list;
my @good;

if ($type eq "new"){
	$oi=1;
	$ni=2;
	$ai=0;
	$pi=3;
	$ti=1;
}
elsif ($type eq "old"){
	$oi=1;
	$ni=0;
	$ai=2;
	$pi=3;
	$ti=1;
}
else{
	die ("check_table.pl: valore non valido per -type\n");
}

#creare array con i taxid necessari
open (Fhi,"<$infile") or die ("check_table.pl: Impossibile aprire $infile\n");
while (<Fhi>){
	chomp;
	$pattern='\d{3}_(\d+)';
	$_=~/$pattern/;
	push (@list,$1);
}
close Fhi;

open (Fhi,"<$table") or die ("check_table.pl: Impossibile aprire $table\n");
while(<Fhi>){
	chomp;
	my @line = split(/\t/,$_);
	$org=$line[$oi];
	$originals{$org} = $_;
	$names{$org}=$line[$ni];
	$taxids{$org}=$line[$ti];
	$ans{$org}=$line[$ai];
	$paths{$org}=$line[$pi];
}
close Fhi;

`rm $outfile` if (-e $outfile);
open (Fho,">>$outfile") or die ("Impossibile creare o modificare $outfile\n");
foreach $org(@list) {
	if (!$taxids{$org}){
		print ("check_table.pl: salto $org - Taxid non presente in tabella\n");
		next;
	}
	elsif ($ans{$org} eq "-"){
		print ("check_table.pl: salto $org - AN corrispondente non presente in tabella\n");
		next;
	}
	elsif ($names{$org} eq "-"){
		print ("check_table.pl: salto $org - Nome organismo corrispondente non presente in tabella\n");
		next;
	}
	elsif ($paths{$org} eq "-"){
		print ("check_table.pl: salto $org - Percorso sito ftp NCBI non presente in tabella\n");
		next;
	}
	else {
		printf Fho "$originals{$org}\n";
	}
}
close Fho;