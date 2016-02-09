#!/usr/bin/perl -w

#il file deve avere le intestazioni di colonna con gli accession number


for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-file"){ #file ortholuge
		$file = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-blastdir"){ #cartella coi blast
		$blastdir = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-query"){ #genoma query per le lunghezze
		$querygen = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

die ("find_best_tblastn.pl: blast directory non fornita\n") if (not($blastdir));
die ("find_best_tblastn.pl: file ortholuge non fornito\n") if (not($file));
die ("find_best_tblastn.pl: genoma query non fornito\n") if (not($querygen));

my $qsuf = "faa";
my $ssuf = "fna";

#ottenere le lunghezze
$/=">";
open (Fhi,"<$querygen") or die ("Impossibile aprire $querygen\n");
$r=1;
while (<Fhi>){
	chomp;
	if ($r==1){
		$r++;
		next;
	}
	@rec = split (/\n/,$_);
	$seq = join ("",@rec[1..$#rec]);
	$len = length ($seq);
	$db{$rec[0]} = $len;
}
close Fhi;
$/="\n";

open (Fhi1,"<$file") or die ("find_best_blast.pl: impossibile aprire $file\n");
$i=1;
while (<Fhi1>){
	chomp;
	@inline = split(/\t/,$_);
	if ($i == 1){
		@orgs = @inline;
		print ("$_\n");
		$i++;
		next;
	}
	$query = $inline[0];
	my @outline;
	push (@outline, $query);
	for ($q=1;$q<=$#inline;$q++){
		$subj = $inline[$q];
		if ($subj eq "-"){
			my $org1 = $orgs[0];
			my $org2 = $orgs[$q];
			my $blastfile = "$blastdir\/tblastn_${org2}.${ssuf}_vs_${org1}.${qsuf}.txt";
			my $seqlen = $db{$query};
			my $parse = `grep "# Query: $query" $blastfile -A 3 | tail -1`;
			my $lim = $seqlen * 0.6;
			if ($parse =~ /^\S+\s+(\S+)\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)/ and not ($parse =~ /#/) and ($2>=$lim)){
				my $sstart = $3;
				my $send = $4;
				my $san = $1;
				if ($sstart<$send){
					$limits = "${sstart}-${send}";
				}
				else {
					$limits = "c${send}-${sstart}"
				}
				push (@outline, "bth_$san\|$limits");
			}
			else {
				push (@outline, "-");
			}
		}
		else {
			push (@outline, $subj);
		}
	}
	my $newline = join ("\t",@outline[0..$#outline]);
	print ("$newline\n");
}
close Fhi1;