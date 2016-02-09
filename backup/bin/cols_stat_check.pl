#!/usr/bin/perl -w

my $coeff = 1;

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-infile"){
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("stat_check.pl: $infile non trovato\n") if (!-e $infile);
	}
	elsif ($ARGV[$i] eq "-statfile"){
		$statfile = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("stat_check.pl: $statfile non trovato\n") if (!-e $statfile);		
	}
	elsif ($ARGV[$i] eq "-mode"){
		$mode = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("stat_check.pl: -mode può essere solo mean o median\n") if (not($mode eq "mean" or $mode eq "median"));		
	}
	elsif ($ARGV[$i] eq "-ortdir"){
		$ortdir = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("stat_check.pl: $ortdir non trovato\n") if (!-e $ortdir);
	}
	elsif ($ARGV[$i] eq "-coeff"){
		$coeff = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

die ("stat_check.pl: -infile non specificato\n") if (not $infile);
die ("stat_check.pl: -statfile non specificato\n") if (not $statfile);
die ("stat_check.pl: -mode non specificato\n") if (not $mode);
die ("stat_check.pl: -ortdir non specificato\n") if (not $ortdir);

#indicizzare statfile
open (Fhi,"<$statfile") or die ("stat_check.pl: impossibile aprire $statfile\n");
$i=0;
while (<Fhi>){
	if ($i == 0){
		$i++;
		next;
	}
	chomp;
	my @line = split (/\t/, $_);
	my $gen = $line[1];
	$mean{$gen} = $line[2];
	$stdev{$gen} = $line[3];
	$median{$gen} = $line[4];
	$mad{$gen} = $line[5];
}
close Fhi;

#scorrere il file
open (Fhi,"<$infile") or die ("stat_check.pl: impossibile aprire $infile\n");
$q=0;
while(<Fhi>){
	chomp;
	my @line = split (/\t/, $_);
	if ($q == 0){
		my $fline = join ("\t",@line[0..$#line]);
		print "$fline\n";
		@genomes = @line;
		$queryorg = $genomes[0];
		$q++;
		next;
	}
	my $query = $line[0];
	my @outline;
	push (@outline, $line[0]);
	for ($z=1;$z<=$#line;$z++){
		my $subjorg = $genomes[$z];
		my $dirname = join("_","???_$queryorg","???_$subjorg");
		my $filename = join("_",$dirname,"_???_$subjorg");
		if ($mode eq "mean"){
			$err = $coeff * $stdev{$subjorg};
			$limit = $mean{$subjorg} + $err;
		}
		else {
			$err = $coeff * $mad{$subjorg};
			$limit = $median{$subjorg} + $err;
		}
		my $seq = $line[$z];
		if ($seq =~ /^brh_(\S+)/){
			my $base = $1;
			my $a = `grep -h -P "^$query\t$base\t$base" $ortdir/$dirname/$filename.txt`;
			my @parse = split(/\t/, $a);
			my $dist = $parse[3];
			$prefix = ($dist <= $limit)?"cbr":"fbr";
			$newseq = "${prefix}_$base";
		}
		else {
			$newseq = $seq;
		}
		push (@outline,$newseq);
	}
	my $newline = join ("\t", @outline[0..$#outline]);
	print "$newline\n";
}
close Fhi;
