#!/usr/bin/perl -w


for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-db"){
		$db = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("reformat_db.pl: $db non esiste/n") if (!-e $db);
	}
	elsif ($ARGV[$i] eq "-type"){
		$seqtype = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}
my @out;

$/=">";

open (Fhi,"<$db") or die ("reformat_db.pl: $db non trovato\n");
while (<Fhi>){
	chomp;
	if ($seqtype eq "protein"){
		if (/\d+\|ref\|(\S+)\.\d+|\S+\n/){
			my $acc = ">$1";
			my @a = split(/\n/,$_);
			push (@out,join("\n",$acc,@a[1..$#a]));
		}
	}
	elsif ($seqtype eq "dna"){
		if (/gi\|\d+\|\w+?\|(\S+?).\d\|:(\S+?)\s/){
			my $acc = ">$1\|$2";
			my @a = split(/\n/,$_);
			push (@out,join("\n",$acc,@a[1..$#a]));
		}
	}
	elsif ($seqtype eq "genomic"){
		if (/gi\|\d+\|\w+?\|(\S+?.\d)\|\s(\S+)/){
			my $acc = ">$1 $2";
			my @a = split(/\n/,$_);
			push (@out,join("\n",$acc,@a[1..$#a]));
		}
	}
	else {
		die ('reformat_db.pl: -type può essere solo "dna" o "protein" o "genomic"');
	}
}
close Fhi;
print (join("\n",@out[0..$#out]));
