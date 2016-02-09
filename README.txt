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
						paths. See default table for an example. DEFAULT: ./source/prokaryotes.txt
	-table-location		"online" or "offline". DEFAULT: offline. Change to online if you provided a URL in -source-table
						and you want to download it
	-correct-table		which ANs/taxids/organism/etc. You want to remove from the table. Useful in case of multiple ANs
						corresponding to the same taxid to avoid accidental overwrite
	-skip				which steps of this pipeline you want to skip. Can be "tree", "download", "tblastn", "blast",
						"reformat", "ortholuge", "stat", "bbh", "bth". You can select multiple values separating them
						with a comma
	-jump-to			start the pipeline directly from a checkpoint. NOTE: you must have in you work directory ALL the
						files and folders created by the steps you skipped. Can be "download", "blast", "ortholuge" or
						"analysis"
	-quit-after			stop the pipeline at a certain checkpoint. Cleanup step will be skipped with this option allowing
						you to restart from where you stopped. Can be "end", "table", "download", "blast" o "ortholuge"
	-bindir				the directory where the scripts invoked by the pipeline are stored. DEFAULT: ./bin
	-tree				the file containing the phylogenetic tree with taxids as leaves. COMPULSORY
	-begin				one of the two organisms which will determine the borders of the organism rage to be analized.
						You must specify a taxid. COMPULSORY
	-query				taxid of the query genome. COMPULSORY
	-outgroup			taxid of the organism you wish to use as outgroup to every other organism.
	-stop				the other of the two organisms which will determine the borders of the organism rage to be
						analized. You must specify a taxid. COMPULSORY
	-type				is your sequence "dna" or "protein"? COMPULSORY
	-expect				E-value threshold for BLAST. DEFAULT: 1e-04
	-ortholuge			directory where you have installed Ortholuge. COMPULSORY
	-workdir			working directory. DEFAULT: ./
	-nofilt				use this option if you do not want to filter Ortholuge results
	-c1, -c2, -c3		coefficients which will be used to determine the thresholds for the filter on Ortholuge results
						relative to R1, R2, R3 respectively. DEFAULT: 1.5, 1.5, 3
	-cons				how many outgroups must at leas confirm your orthologs pairs? DEFAULT: 1
	-make-dir			don't run
	