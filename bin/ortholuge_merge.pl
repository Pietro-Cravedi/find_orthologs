#!/usr/bin/perl -w

#unisce i risultati di ortholuge filtrati e non filtrati

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-filtered"){ #file ortholuge
		$filtered = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-unfiltered"){ #cartella coi blast
		$unfiltered = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

die ("ortholuge_merge.pl: -filtered non definito\n") if (not($filtered));
die ("ortholuge_merge.pl: -unfiltered non definito\n") if (not($unfiltered));

#leggere i file
open (Fhi, "<$filtered") or die ("ortholuge_merge.pl: impossibile aprire $filtered\n");
$i=0;
while (<Fhi>){
	chomp;
	if ($i == 0){
		$i++;
		print "$_\n";
		next;
	}
	my @line = split (/\t/, $_);
	$fil{$line[0]} = join ("\t", @line[1..$#line]);
}
close Fhi;

my @form;
open (Fhi, "<$unfiltered") or die ("ortholuge_merge.pl: impossibile aprire $unfiltered\n");
$q=0;
while (<Fhi>){
	chomp;
	my @line = split (/\t/, $_);
	if ($q == 0){
		for ($z=0;$z<=$#line;$z++){
			push (@form, "-");
		}
		$q++;
		next;
	}
	$nofil{$line[0]} = join ("\t", @line[1..$#line]);
}
close Fhi;

@ans=keys(%fil);
foreach $acc(@ans) {
	@out=@form;
	$out[0]=$acc;
	@filter = split(/\t/,$fil{$acc});
	@nofilter = split (/\t/,$nofil{$acc});
	for ($c=0;$c<=$#form-1;$c++){
		$pos=$c+1;
		if (($filter[$c]) and (not($filter[$c] eq "-"))){
			$out[$pos]="ssd_$filter[$c]";
		}
		elsif (($filter[$c] eq "-") and ($nofilter[$c]) and (not($nofilter[$c] eq "-"))){ #<-mod qui, aggiunta prima condizione
			if (not($nofilter[$c] =~ /^brh/)){
				$out[$pos]="nsd_$nofilter[$c]";
			}
			else {
				$out[$pos]="$nofilter[$c]";
			}
		}
	}
	$outline = join ("\t", @out[0..$#out]);
	print "$outline\n";
}