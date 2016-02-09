#!/usr/bin/perl -w

#modifica un file di output di ortholuge aggiungendo le sequenze che non hanno la terna di BRH
#funziona anche su file di ortholuge filtrati con ortholuge_filter.pl
#il file del genoma deve essere lo stesso usato per ortholuge
#uso: perl ortholuge_pad.pl -f [file con ortologhi] -g [genoma] -t [true/false]


for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-f"){
		$ortfile = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-g"){
		$genome = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-t"){
		$header = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif (($ARGV[$i] eq "-h") or ($ARGV[$i] eq "--help")) {
		print "Aggiunge ad un file di output di ortholuge le sequenze per cui non è stata trovata una tripletta.\n";
		print "Le sequenze sono prese da un file con tutte le sequenze proteiche dell'organismo.\n\n";
		print "Uso:\n\tperl ortholuge_pad.pl [PARAMETRI]\n\n";
		print "Opzioni disponibili:\n";
		print "\t-f [FILE]\tFile con i risultati di ortholuge. Può essere con o senza distanze. I rapporti vanno rimossi.\n";
		print "\t-g [FILE]\tFile con le sequenze proteiche dell'organismo query in formato FASTA.\n";
		print "\t-h|--help\t Visualizza l'help per lo script.\n\n";
		print "-f e -g sono obbligatori.\n";
		die ("\n");
	}
}

die ("ortholuge_pad.pl: Mancano uno o più parametri obbligatori.\n") if ((not $ortfile) or (not $genome));
die ("ortholuge_pad.pl: -t può essere solo true o false\n") if (not(($header eq "true") or ($header eq "false")));

my @anlist;
my %ortholuge;
my %out;
my @frame;

#recuperare AN
$/=">";
open (Fhi,"<$genome") or die ("ortholuge_pad.pl: $genome non trovato\n");
while (<Fhi>){
	chomp;
	if (/(\w\w_\d+)\n/){
		my $acc=$1;
		push @anlist, $acc;
	}
	elsif (/(\w\w_\d+\|\S+)\n/){
		my $acc=$1;
		push @anlist, $acc;
	}
}
close Fhi;
$/="\n";

#identifica il tipo di file e sceglie il padder
open (Fhi,"<$ortfile") or die ("ortholuge_pad.pl: $ortfile non trovato\n");
$i=0;
while (<Fhi>){
	if ($header eq "true" and $i == 0){
		$i=1;
		next;
	}
	my @b = split (/\t/, $_);
	for ($i=1;$i<=$#b;$i++){
		push (@frame, "-");
	}
last;
}
close Fhi;
$pad=join("\t",@frame[0..$#frame]);

#indicizzare file ortholuge
open (Fhi,"<$ortfile");
$q=0;
while (<Fhi>){
	if ($header eq "true" and $q == 0){
		print($_);
		$q=1;
		next;
	}
	chomp;
	my $line = $_;
	my @a = split (/\t/, $line);
	$ortholuge{$a[0]}=join("\t",@a[1..$#a]);
}
close Fhi;

#confronto
foreach $an(@anlist){
	if ($ortholuge{$an}){
		$out{$an}="$ortholuge{$an}\n";
	}
	else {
		$out{$an}="$pad\n";
	}
}

#output
foreach $o(keys(%out)){
	print ("$o\t$out{$o}");
}