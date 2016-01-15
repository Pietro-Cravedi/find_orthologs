Help file for find_orthologs.sh
Pietro Cravedi 2015

find_orthologs.sh is a pipeline which applies Ortholuge (Fulton et al., 2006) to find orthologous genes for each gene of a query genome in a given number of target genomes. This pipeline runs on Linux

Requirements:
-Ortholuge (http://www.pathogenomics.ca/ortholuge/download.html) and relative required programs
-BLAST suite version 2.2.26 or later
-Perl version 5.10.1 or later
-R version 3.2.3 or later
-Wget 1.12 or later (should be included in your Linux build)
-Internet connection (to download genomes)

Avaiable options:
	-help				display this file
	-source-dir			define directory with source genomes if you don't want to download them with this pipeline
						the directory must be organized like this:
							raw_genomes: directory with files containing collections of CDS or protein sequences as downloaded from NCBI, each representing an organism
							raw_whole_genomes: directory with files containing whole genome sequences as downloaded from NCBI, each representing an organism
						the other 2 directories will be created by this pipeline
						if you use this option you should also use -skip download
	-source-table		file path of the correspondence table containing ANs, organism names, taxids and download 
						paths. See default table for an example. Default: ./source/prokaryotes.txt
	-table-location		"online" or "offline". Default: offline. Change to online if you provided a URL in -source-table
						and you want to download it
	-correct-table		which ANs/taxids/organism/etc. You want to remove from the table. Useful in case of multiple ANs
						corresponding to the same taxid to avoid accidental overwrite
	-skip				which steps of this pipeline you want to skip. Can be "tree", "download", "tblastn", "blast",
						"reformat", "ortholuge", "stat", "bbh", "bth". You can select multiple values separating them
						with a comma
	"-jump-to") shift; jump=$1;;
	"-quit-after") shift; quit=$1;;
	"-bindir") shift; bindir=$1;;
	"-tree") shift; tree=$1;;			#obbligatorio
	"-begin") shift; firstorg=$1;;		#obbligatorio
	"-query") shift; query=$1;;			#obbligatorio
	"-outgroup") shift; out_taxid=$1;;
	"-stop") shift; lastorg=$1;;		#obbligatorio
	"-type") shift; seqtype=$1;;		#obbligatorio
	"-expect") shift; expect=$1;;
	"-ortholuge") shift; ortbindir=$1;;	#obbligatorio
	"-workdir") shift; workdir=$1;;
	"-nofilt") nofilt=1;;
	"-mode") shift; mode=$1;;
	"-c1") shift; c1=$1;;
	"-c2") shift; c2=$1;;
	"-c3") shift; c3=$1;;
	"-cons") shift; clim=$1;;
	"-coeff") shift; coeff=$1;; #coefficiente per il controllo statistico
	"-make-dir") makedir=1;;
	