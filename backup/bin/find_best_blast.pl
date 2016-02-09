#!/usr/bin/perl -w

#il file deve avere le intestazioni di colonna con gli accession number


for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-file"){ #file ortholuge
		$file = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-blastdir"){ #cartella coi blast
		$blastdir = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-type"){ #tipo di sequenza
		$type = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("find_best_blast.pl: blast directory non fornita\n") if (not($blastdir));
die ("find_best_blast.pl: file ortholuge non fornito\n") if (not($file));
die ("find_best_blast.pl: tipo di sequenza non indicato\n") if (not($type));

if ($type eq "protein") {
	$suffix="faa";
}
elsif ($type eq "dna") {
	$suffix="ffn";
}
else {
	die ("find_best_blast.pl: -type può essere solo dna o protein\n");
}

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
	my @outline = ($query);
	for ($q=1;$q<=$#inline;$q++){
		$subj = $inline[$q];
		if ($subj eq "-"){
			my $org1 = $orgs[0];
			my $org2 = $orgs[$q];
			my $blastfile = "$blastdir\/blast_${org2}.${suffix}_vs_${org1}.${suffix}.txt";
			my $parse = `grep "Query= $query" $blastfile -A 13 | tail -1`;
			if ($parse =~ /^(\S+)\s/){
				push (@outline, "bbh_$1");
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