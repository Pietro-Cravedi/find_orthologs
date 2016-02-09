#!/usr/bin/perl -w

my %urls;

for ($i=0;$i<=$#ARGV;$i++){
	if ($ARGV[$i] eq "-table"){ #tabella di conversione
		$table = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-file"){ #file con lista di organismi
		$infile = $ARGV[$i+1]  if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-outdir"){ #directory dove salvare le sequenze
		$outdir = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
	elsif ($ARGV[$i] eq "-type"){ #tipo di sequenza
		$type = $ARGV[$i+1] if ($ARGV[$i+1]);
	}
}

die ("download_genomes.pl: Tabella di conversione non specificata\n") if (!$table);
die ("download_genomes.pl: File di input non specificato\n") if (!$infile);
die ("download_genomes.pl: Directory di output non specificata\n") if (!$type);

`mkdir $outdir` if (!-e $outdir);

if ($type eq "cds"){
	$suffix = "ffn";
}
elsif ($type eq "protein"){
	$suffix = "faa";
}
elsif ($type eq "genomic"){
	$suffix = "fna";
}
else{
	die("download_genomes.pl: -type può essere solo cds, genomic o protein\n");
}

open (Fhi,"<$table") or die ("download_genomes.pl: Impossibile aprire $table");
while (<Fhi>){
	chomp;
	my @line = split(/\t/,$_);
	$line[2]=~/(\S+).\d/;
	my $an = $1;
	my $path = $line[3];
	$urls{$an}=$path;
}
close Fhi;


open (Fhi,"<$infile") or die ("download_genomes.pl: Impossibile aprire $infile\n");
while(<Fhi>){
	chomp;
	$_=~/^\d{3}_(\S+)/;
	my $acc = $1;
	my $path = "ftp://ftp.ncbi.nlm.nih.gov/genomes/archive/old_refseq/ASSEMBLY_BACTERIA/$urls{$acc}/*.$suffix";
	print "Downloading: $path\n";
	`wget -qO $outdir\/$acc.$suffix $path`;
}
close Fhi;