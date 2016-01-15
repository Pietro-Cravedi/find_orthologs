#!/usr/bin/perl -w

my %ans;

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-table"){
		$table = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-file"){
		$infile = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-type"){
		$type = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("taxid2genomes.pl: Tabella di conversione non specificata\n") if (!$table);
die ("taxid2genomes.pl: File da processare non specificato\n") if (!$infile);
die ("taxid2genomes.pl: Tipo di file (list o triplets) non specificato\n") if (!$type);

#indicizzare tabella
open (Fhi,"<$table") or die ("taxid2genomes.pl: Impossibile aprire $table");
while (<Fhi>){
	chomp;
	my @line = split(/\t/,$_);
	my $taxid = $line[1];
	$line[2]=~/(\S+).\d/;
	my $an = $1;
	my $path = $line[3];
	$ans{$taxid}=$an;
}
close Fhi;

open (Fhi,"<$infile") or die ("taxid2genomes.pl: Impossibile aprire $infile\n");
while(<Fhi>){
	chomp;
	if ($type eq "list"){
		$_=~/(\d{3})_(\d+)/;
		my $count = $1;
		my $id = $2;
		print (join ("_",$count,$ans{$id}),"\n");
	}
	elsif ($type eq "triplets"){
		$_=~/(\d{3})_(\d+)\t(\d{3})_(\d+)\t(\d{3})_(\d+)/;
		my ($c1,$id1,$c2,$id2,$c3,$id3) = ($1,$2,$3,$4,$5,$6);
		my $acc1 = join("_",$c1,$ans{$id1});
		my $acc2 = join("_",$c2,$ans{$id2});
		my $acc3 = join("_",$c3,$ans{$id3});
		print ("$acc1\t$acc2\t$acc3\n");
	}
	else{
		close Fhi;
		die ("taxid2genomes.pl: -type può essere solo list o triplets\n");
	}
}
close Fhi;