#!/usr/bin/perl -w

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-file"){
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("parse_results.pl: $infile non trovato\n") if (!-e $infile);
	}
	elsif ($ARGV[$i] eq "-remove"){
		$remove = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
}

die ("parse_results.pl: -file non specificato\n") if (not $infile);
die ("parse_results.pl: -remove non specificato\n") if (not $remove);

@remlist = split (/,/, $remove);
foreach $i(@remlist){
	die ("parse_results.pl: i prefissi accettati sono ssd, nsd, cbr, fbr, bbh, bth, brh\n") if (not($i eq "ssd" or $i eq "nsd" or $i eq "cbr" or $i eq "fbr" or $i eq "bbh" or $i eq "bth" or $i eq "brh"));
}

open (Fhi,"<$infile") or die ("Impossibile aprire $infile\n");
while (<Fhi>){
	chomp;
	@line = split(/\t/,$_);
	for ($q=1;$q<$#line;$q++){
		my $res = $line[$q];
		foreach $prefix(@remlist){
			$line[$q] = "-" if ($res =~ /^$prefix/);
		}
	}
	$outline = join("\t",@line[0..$#line]);
	print "$outline\n";
}
close Fhi;