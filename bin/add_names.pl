#!/usr/bin/perl -w

#usage perl add_names.pl -m [replace/add] -i [file] -t [correspondence table] -af [AN column] -nf [names column]

$mode="add";

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-i"){
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("add_names.pl: $infile not found\n") if (!-e $infile);
	}
	elsif ($ARGV[$i] eq "-t"){
		$table = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("add_names.pl: $table not found\n") if (!-e $table);
	}
	elsif ($ARGV[$i] eq "-af"){
		$accfield = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-nf"){
		$namfield = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-m"){
		$mode = $ARGV[$i+1]  if ($ARGV[$i+1]);
		die ("add_names.pl: -m can only be replace or add\n") if (not(($mode =~ "replace") or ($mode =~ "add"))); 
	}
}

die ("add_names.pl: Option -i not found\n") if (not $infile);
die ("add_names.pl: Option -t not found\n") if (not $table);
die ("add_names.pl: Option -af not found\n") if (not $accfield);
die ("add_names.pl: Option -nf not found\n") if (not $namfield);


#indiciZE TABLE - acc => name
open (Fhi,"<$table");
while (<Fhi>){
	my @line = split(/\t/,$_);
	my $name = $line[$namfield-1];
	my $acc = $line[$accfield-1];
	$acc =~ s/\.\d//g;
	$table{$acc}=$name;
}
close Fhi;

#fetch first line
open (Fhi, "<$infile");
while (<Fhi>){
	chomp;
	$fline = $_;
	last;
}
close Fhi;

my @out;
my @line = split(/\t/, $fline);

foreach $an(@line){
	($an eq "Description") ? push (@out, $an) : push (@out, $table{$an});
}

print (join("\t",@out[0..$#out]),"\n");
($mode =~ "replace") ? $rest=`tail -n +2 $infile` : $rest=`cat $infile`;
print "$rest\n";