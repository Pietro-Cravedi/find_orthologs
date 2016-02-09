#!/usr/bin/perl -w

#traduce le sequenze nucleotidiche in un file in sequenze proteiche - gli stop vengono tradotti in X
#uso: perl translate.pl -f [file]
#output a schermo

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-f"){
		$infile = $ARGV[$i+1] if ($ARGV[$i+1]);
		die ("translate.pl: $infile non esiste\n") if (!-e $infile);
	}
}

sub translate {
	my $nucseq = shift;
	$aminoseq = "";
	my %code = ('TCA'=>'S','TCC'=>'S','TCG'=>'S','TCT'=>'S','TTC'=>'F','TTT'=>'F','TTA'=>'L','TTG'=>'L','TAC'=>'Y','TAT'=>'Y','TAA'=>"X",'TAG'=>"X",'TGC'=>'C','TGT'=>'C','TGA'=>"X",'TGG'=>'W','CTA'=>'L','CTC'=>'L','CTG'=>'L','CTT'=>'L','CCA'=>'P','CCC'=>'P','CCG'=>'P','CCT'=>'P','CAC'=>'H','CAT'=>'H','CAA'=>'Q','CAG'=>'Q','CGA'=>'R','CGC'=>'R','CGG'=>'R','CGT'=>'R','ATA'=>'I','ATC'=>'I','ATT'=>'I','ATG'=>'M','ACA'=>'T','ACC'=>'T','ACG'=>'T','ACT'=>'T','AAC'=>'N','AAT'=>'N','AAA'=>'K','AAG'=>'K','AGC'=>'S','AGT'=>'S','AGA'=>'R','AGG'=>'R','GTA'=>'V','GTC'=>'V','GTG'=>'V','GTT'=>'V','GCA'=>'A','GCC'=>'A','GCG'=>'A','GCT'=>'A','GAC'=>'D','GAT'=>'D','GAA'=>'E','GAG'=>'E','GGA'=>'G','GGC'=>'G','GGG'=>'G','GGT'=>'G');
	for ($i=0; $i < (length($nucseq)); $i+=3){
		my $codon=substr($nucseq,$i,3);
		my $ucodon=uc($codon);
		$residue = $code{$ucodon} or $residue = "X";
		$aminoseq = join("",$aminoseq,$residue);
	}
	print $aminoseq;
}

die ("translate.pl -f non specificato\n") if (not($infile));

$/=">";
$i=0;
open (Fhi,"<$infile") or die ("translate.pl: Impossibile aprire $infile\n");
while (<Fhi>){
	if ($i==0){
		$i=1;
		next;
	}
	chomp;
	my @rec = split (/\n/,$_);
	my $seq = join ("",@rec[1..$#rec]);
	print ">$rec[0]\n";
	&translate($seq);
}
close Fhi;
$/="\n";