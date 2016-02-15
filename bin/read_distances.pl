#!/usr/bin/perl -w

$normalize="yes";
$description="yes";

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-file"){ #find_orthologs results file
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("read_stat.pl: $infile not found\n") if (!-e $infile);
	}
	elsif ($ARGV[$i] eq "-genrow"){ #row with genomes accession numbers as called by findorthologs
		$genrow = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-header"){ #number of header lines
		$header = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-ortdir"){ #ortholuge results directory created by find_orthologs
		$ortdir = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("read_stat.pl: $ortdir not found\n") if (!-e $ortdir);
	}
	elsif ($ARGV[$i] eq "-statfile"){ #statistics.txt file created by find_orthologs
		$statfile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("read_stat.pl: $statfile not found\n") if (!-e $statfile);
	}
	elsif ($ARGV[$i] eq "-normalize"){ #do you want raw (no) or normalized (yes) distances?
		$normalize = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-description"){
		$description = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("read_stat.pl: -genrow not provided\n") if (not($genrow));
die ("read_stat.pl: -file not provided\n") if (not($infile));
die ("read_stat.pl: -statfile not provided\n") if ((not($statfile)) and ($normalize eq "yes"));
die ("read_stat.pl: -ortdir not provided\n") if (not($ortdir));
die ("read_stat.pl: -header not provided\n") if (not($header));

#leggere AN genomi - si trovano sulla riga $anrow
$c=1;
open (Fhi,"<$infile") or die ("read_stat.pl: could not open $infile\n");
while(<Fhi>){
	if ($c == $genrow) {
		chomp;
		#print "ok\n";
		my @line = split (/\t/,$_);
		$querygen = $line[0];
		@subgen = @line[1..$#line];
		last;
	}
	else{
		$c++;
	}
}
close Fhi;

#prendere le distanze tra le specie - solo se -normalize yes
if ($normalize eq "yes"){
	$r=1;
	open (Fhi,"<$statfile") or die ("read_stat.pl: could not open $statfile\n");
	while (<Fhi>){
		chomp;
		if ($r==1){
			$r++;
			next;
		}
		my @line = split(/\t/,$_);
		$dist{$line[1]}=$line[2];
	}
	close Fhi;
}
elsif (not(($normalize eq "yes") or ($normalize eq "no"))){
	die ("read_stat.pl: -normalize can only be yes or no\n"); 
}

#print "$querygen\n";

#indicizzare i file di ortholuge
foreach $gen(@subgen){
	my $dir = "${ortdir}/???_${querygen}_???_${gen}/???_${querygen}_???_${gen}__???_${gen}.txt";
	my $a = `ls $dir`;
	#print "$a\n";
	my @b = split(/\//, $a);
	my $file = $b[$#b];
	$file =~ /(\d\d\d)_\w\w_\S+_(\d\d\d)_\w\w_\S+__(\d\d\d)_\w\w_\S+.txt/;
	my $path = "${ortdir}/${1}_${querygen}_${2}_${gen}/${1}_${querygen}_${2}_${gen}__${3}_${gen}.txt";
	
	open (Fhi,"<$path") or die ("could not open $path\n");
	$i=1;
	while (<Fhi>){
		if ($i < 2){
			$i++;
			next;
		}
		chomp;
		my @line = split(/\t/,$_);
		my $acc = $line[0];
		my $dist = $line[3];
		$$gen{$acc}=$dist;
	}
	close Fhi;
}
print (join ("\t",$querygen,@subgen[0..$#subgen]),"\n");

#ottenere chiavi e creare file di output
$q=1;
open (Fhi, "<$infile");
while (<Fhi>){
	if ($q <= $header){
		$q++;
		next;
	}
	chomp;
	my @line = split(/\t/,$_);
	my $an = $line[0];
	print "$an";
	if ($description eq "yes"){
		$maxind=$#line-1;
	}
	elsif ($description eq "no"){
		$maxind=$#line;
	}
	else {
	 die ("read_stat.pl: -description can only be yes or no\n");
	}
	for ($i=1;$i<=$maxind;$i++){
		my $gen = $subgen[$i-1];
		if (($$gen{$an}) and not($line[$i] eq "-")){
			my $val = $$gen{$an};
			if ($normalize eq "yes"){
				$spdist = $dist{$gen};
				$val = $val / $spdist;
			}
			print "\t$val";
		}
		else {
			print "\t-";
		}
	}
	print "\n";
}
close Fhi;