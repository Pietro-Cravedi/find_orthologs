#!/usr/bin/perl -w

#usage: perl ortholuge_pad.pl -f [ortholuge file] -g [genome] -t [true/false]


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
		print "Adds to an ortholuge file the triplets for which a triple BRH was not found.\n";
		print "The sequence list is taken from organism proteome.\n\n";
		print "Usage:\n\tperl ortholuge_pad.pl [OPTIONS]\n\n";
		print "Options:\n";
		print "\t-f [FILE]\tOrtholuge file. Can be with or without distances. Ratios must be removed.\n";
		print "\t-g [FILE]\tFASTA format proteome file.\n";
		print "\t-h|--help\t Prints help.\n\n";
		print "-f and -g are mandatory.\n";
		die ("\n");
	}
}

die ("ortholuge_pad.pl: One or more mandatory options are missing\n") if ((not $ortfile) or (not $genome));
die ("ortholuge_pad.pl: -t can only be true or false\n") if (not(($header eq "true") or ($header eq "false")));

my @anlist;
my %ortholuge;
my %out;
my @frame;

#recuperare AN
$/=">";
open (Fhi,"<$genome") or die ("ortholuge_pad.pl: $genome not found\n");
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
open (Fhi,"<$ortfile") or die ("ortholuge_pad.pl: $ortfile not found\n");
$i=0;
while (<Fhi>){
	if ($header eq "true" and $i == 0){
		$i=1;
		my @b = split (/\t/, $_);
		for ($i=1;$i<=$#b;$i++){
			push (@frame, "-");
		}
		last;
	}
	my @c = split (/\t/, $_);
	for ($i=1;$i<=$#c;$i++){
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