#!/usr/bin/perl -w

#da usare PRIMA di add_description.pl

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-file"){
		$file = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("remove_duplicates_bbh.pl: -file non fornito\n") if (!$file);

open (Fhi,"<$file") or die ("Impossibile aprire $file\n");
$i=0;
while (<Fhi>){
	chomp;
	#saltare riga titoli
	if ($i==0){
		$i++;
		print "$_\n";
		next;
	}
	my @line = split(/\t/,$_);
	for ($q=1;$q<=$#line;$q++){
		if ($line[$q] =~ /^bbh_(\S+)/){
			my $acc = $1;
			my $a = `grep "$acc" $file`;
			my @parse = split(/\n/,$a);
			if ($#parse > 1){
				foreach $b(@parse){
					my @pline = split(/\t/, $b);
					$line[$q] = "-" if (not($pline[$q] =~ /^bbh/));
				}
			}
		}
	}
	my $newline = join("\t", @line[0..$#line]);
	print "$newline\n";
}
close Fhi;