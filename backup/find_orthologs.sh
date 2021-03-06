#!/bin/sh

#valori di default
source_tab="./source/prokaryotes.txt"
table_location="offline"
bindir="./bin/"
expect="1e-04"
c1=1
c2=1
c3=1
workdir="./workdir/"
quit="end"
clim=1
dnasuf="ffn"
protsuf="faa"
mode="mean"
nofilt=0
makedir=0
do_tree=1
do_download=1
do_tblastn=1
do_blast=1
do_reformat=1
do_ortholuge=1
do_stat=1
do_bbh=1
do_bth=1
coeff=1

#acquisizione argomenti
while [ $1 ]; do
	case $1 in
		"-source-dir") shift; custom_source=$1;;
		"-source-table") shift; source_tab=$1;;
		"-table-location") shift; table_location=$1;;
		"-correct-table") shift; purge=$1;;
		"-skip") shift; skip=$1;;
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
		"-help") cat ./README.txt; exit;;
		*) echo "Opzione errata: $1"; exit;;
	esac
	shift
done

#controlli su argomenti
if [ ! -d $ortbindir ]; then echo "-ortbindir non esiste o non è una directory"; exit; fi
if [ ! -d $bindir ]; then echo "-bindir non esiste o non è una directory"; exit; fi
if [ $custom_source -a ! -d $custom_source ]; then echo "-source-dir non esiste o non è una directory"; exit; fi
if [ ! $seqtype ]; then echo "-seqtype non specificato"; exit; fi
if [ ! $tree ]; then echo "-tree non specificato"; exit; fi
if [ ! $query ]; then echo "-query non specificato"; exit; fi
if [ ! $lastorg ]; then echo "-stop non specificato"; exit; fi
if [ ! $firstorg ]; then echo "-begin non specificato"; exit; fi
if [ $quit != "download" -a $quit != "blast" -a $quit != "ortholuge" -a $quit != "end" -a $quit != "table" ]; then echo "-quit-after può essere solo end, table, download, blast o ortholuge"; exit; fi
if [ $mode != "mean" -a $mode != "median" ]; then echo "-mode può essere solo mean o median"; exit; fi
if [ $table_location != "online" -a $table_location != "offline" ]; then echo "-table_location può essere solo online o offline"; exit; fi

#inizializzazione variabili - cartelle
homedir=`pwd`
sourcedir="$workdir/source/"
if [ $custom_source ]; then sourcedir=$custom_source; fi
blasttmpdir="$workdir/blast_tmp_$query/"
blastdir="$workdir/blast/"
tblastndir="$workdir/tblastn/"
tmpdir="$workdir/tmp_$query/"
tmpfiltdir="$tmpdir/filtered_$query/"
tmpunfiltdir="$tmpdir/unfiltered_$query/"
orttmpdir="$workdir/ortholuge_tmp_$query/" #directory dove lavora ortholuge - ha $query nel nome per consentire operazioni parallele
rawgendir="$sourcedir/raw_genomes/"
refgendir="$sourcedir/ref_genomes/"
tragendir="$sourcedir/translated_genomes/"
rawwholegendir="$sourcedir/raw_whole_genomes/"
refwholegendir="$sourcedir/ref_whole_genomes/"
ortrawdir="$workdir/ortholuge_raw_results/"
guidedir="$workdir/guide_files/"
ortfiltdir="$workdir/ortholuge_filtered_$query/"
unfiltdir="$workdir/ortholuge_unfiltered_$query/"

#inizializzazione variabili - file
settings="$guidedir/settings.txt"
trim_tree="$guidedir/trimmed_tree_$query.txt"
tmpfile="$workdir/tmpfile_$query.txt"
guidefile="$guidedir/ort_guide_$query.txt"
taxidguide="$guidedir/taxid_guide_$query.txt"
taxidlist="$guidedir/taxid_list_$query.txt"
statfile="$guidedir/statistics_$query.txt"
orglist="$guidedir/org_list_$query.txt"
table_raw="$guidedir/raw_tab_$query.txt"
table_int="$guidedir/int_tab_$query.txt"
table_def="$guidedir/def_tab_$query.txt"
table_log="$guidedir/table_log_$query.txt"
out_merged="$workdir/out_merged_$query.txt"
in_merged="$workdir/in_merged_$query.txt"
outfile="$workdir/${firstorg}_to_${lastorg}_q_${query}_e_${expect}"
if [ $nofilt -eq 0 ]; then outfile="${outfile}_c1_${c1}_c2_${c2}_c3_${c3}"; else outfile="${outfile}_nofilt"; fi
outfiltfile="$workdir/filtered_output_$query.txt"
outunfiltfile="$workdir/unfiltered_output_$query.txt"
outfile="${outfile}_m_${mode}_c_${clim}_coeff_${coeff}.txt"
n_outfile="$workdir/n_`basename ${outfile}`"

#inizializzazione variabili - comandi
tree2trip_cmd="Rscript $bindir/tree2triplets.r"
trim_cmd="Rscript $bindir/trim_tree.r"
taxid2genomes_cmd="perl $bindir/taxid2genomes.pl"
download_cmd="perl $bindir/download_genomes.pl"
check_cmd="perl $bindir/check_table.pl"
translate_cmd="perl $bindir/translate.pl"
blastall_cmd="blastall -a 6 -p blastp"
tblastn_cmd="blastall -a 6 -p tblastn -m 9"
ortholuge_cmd="$ortbindir/ortholuge.pl --skip-blast yes --quiet --overwrite yes --bindir $ortbindir --workdir $orttmpdir --seqtype $seqtype"
stat_calc_cmd="Rscript $bindir/calculate_stat_cols.r -outfile $statfile"
stat_check_cmd="perl $bindir/cols_stat_check.pl -mode $mode -coeff $coeff"
ort_filter_cmd="Rscript $bindir/filter_ratios.r"
reformat_db_cmd="perl $bindir/reformat_db.pl -type $seqtype"
reformat_genome_cmd="perl $bindir/reformat_db.pl -type genomic"
out_merge_cmd="perl $bindir/merge_ortholuge_outwalking_new.pl -h true"
in_merge_cmd="perl $bindir/merge_ortholuge_inwalking.pl -h true"
ort_merge_cmd="perl $bindir/ortholuge_merge.pl"
formatdb_cmd="formatdb"
ccount_cmd="perl $bindir/consensus_count.pl -h true"
cfilt_cmd="perl $bindir/consensus_filter.pl -threshold $clim -header true"
pad_cmd="perl $bindir/ortholuge_pad.pl -t true"
remdup_bbh_cmd="perl $bindir/remove_duplicates_bbh.pl"
desc_cmd="perl $bindir/add_description.pl -f 1 -h true"
bbh_cmd="perl $bindir/find_best_blast.pl -type $seqtype -blastdir $blastdir"
bth_cmd="perl $bindir/find_best_tblastn.pl -blastdir $tblastndir"
names_cmd="perl $bindir/add_names.pl -nf 1 -af 3 -m add -t $table_def"

#individuazione checkpoint
if [ $custom_source ]; then
	do_download=0
fi
if [ $skip ]; then
	for i in ${skip//,/ }; do case $i in
	"tree") do_tree=0;;
	"download") do_download=0;;
	"tblastn") do_tblastn=0; do_bth=0;;
	"blast") do_blast=0;;
	"reformat") do_reformat=0;;
	"ortholuge") do_ortholuge=0;;
	"stat")do_stat=0;;
	"bbh") do_bbh=0;;
	"bth") do_bth=0;;
	*) echo "Argomento errato per -skip"; exit;;
	esac; done
fi

if [ $jump ]; then case $jump in
	"download") do_tree=0;;
	"blast") do_tree=0; do_download=0;;
	"ortholuge") do_tree=0; do_download=0; do_blast=0; do_reformat=0;;
	"analysis") do_tree=0; do_download=0; do_blast=0; do_reformat=0; do_ortholuge=0;;
	*) echo "Argomento errato per -jump-to"; exit;;
esac; fi

#definizione suffisso genomi
case $seqtype in 
	"protein") suffix=$protsuf; formatdb_cmd="$formatdb_cmd -p T"; genpath="$refgendir"; downloadtype="protein";;
	"dna") suffix=$dnasuf; formatdb_cmd="$formatdb_cmd -p T"; genpath="$tragendir"; downloadtype="cds";;
	*) echo "-type può essere solo protein o dna"; exit;;
esac

#creazione cartelle
if [ ! -d $workdir ]; then mkdir $workdir; fi
if [ ! -d $sourcedir ]; then mkdir $sourcedir; fi
if [ ! -d $blastdir ]; then mkdir $blastdir; fi
if [ ! -d $blasttmpdir ]; then mkdir $blasttmpdir; fi
if [ ! -d $tblastndir ]; then mkdir $tblastndir; fi
if [ ! -d $tmpdir ]; then mkdir $tmpdir; fi
if [ ! -d $tmpfiltdir ]; then mkdir $tmpfiltdir; fi
if [ ! -d $tmpunfiltdir ]; then mkdir $tmpunfiltdir; fi
if [ ! -d $orttmpdir ]; then mkdir $orttmpdir; fi
if [ ! -d $ortrawdir ]; then mkdir $ortrawdir; fi
if [ ! -d $rawgendir ]; then mkdir $rawgendir; fi
if [ ! -d $refgendir ]; then mkdir $refgendir; fi
if [ ! -d $rawwholegendir ]; then mkdir $rawwholegendir; fi
if [ ! -d $refwholegendir ]; then mkdir $refwholegendir; fi
if [ ! -d $tragendir -a $seqtype == "dna" ]; then mkdir $tragendir; fi
if [ ! -d $guidedir ]; then mkdir $guidedir; fi
if [ ! -d $ortfiltdir ]; then mkdir $ortfiltdir; fi
if [ ! -d $unfiltdir ]; then mkdir $unfiltdir; fi

if [ $makedir == 1 ]; then echo "Struttura cartelle creata"; exit; fi

#creare file con le impostazioni
echo "Query: $query" >> $settings
echo "Start: $firstorg" >> $settings
echo "Stop: $lastorg" >> $settings
echo "Outgroup: $out_taxid" >> $settings
echo "Tree: $tree" >> $settings
echo "Workdir: $workdir" >> $settings
echo "Expect: $expect" >> $settings
echo "C1: $c1" >> $settings
echo "C2: $c2" >> $settings
echo "C3: $c3" >> $settings
[ $nofilt == 0 ] && echo "No filter: no" >> $settings
[ $nofilt == 1 ] && echo "No filter: yes" >> $settings
echo "Mode: $mode" >> $settings
echo "Coefficient: $coeff" >> $settings
echo "Outfile: `basename ${n_outfile}`" >> $settings
echo "" >> $settings

if [ $do_tree == 1 ]; then
	#analisi albero
	$trim_cmd -tree $tree -first $firstorg -query $query -last $lastorg -outfile $trim_tree -outgroup ${out_taxid}
	$tree2trip_cmd -tree $trim_tree -query $query -outfile $taxidguide -outlist $taxidlist

	#recuperare tabella di conversione
	if [ $table_location == "online" ]; then
		wget -qO $table_raw $source_tab
	else
		if [ -r $source_tab ]; then cp $source_tab $table_raw; else echo "Percorso tabella non valido"; exit; fi
	fi
	
	#correzione generica
	if [ $purge ]; then
		for an in ${purge//,/ }; do
			grep $an $table_raw -v > $tmpfile
			mv $tmpfile $table_raw
		done
	fi
	cut -f 1,2,9,24 $table_raw | tail -n +2 > $table_int
	$check_cmd -table $table_int -list $taxidlist -out $table_def > $table_log
	while read line; do 
		taxid=`echo $line|awk '{print $3}'`
		grep -v $taxid $taxidlist > $tmpfile
		mv $tmpfile $taxidlist
		grep -v $taxid $taxidguide > $tmpfile
		mv $tmpfile $taxidguide
	done < $table_log
	
	#conversione dei taxid in an
	$taxid2genomes_cmd -table $table_def -file $taxidguide -type triplets > $guidefile
	$taxid2genomes_cmd -table $table_def -file $taxidlist -type list > $orglist
	if [ -r $tmpfile ]; then rm $tmpfile; fi
else
	echo "Salto lo step di analisi dell'albero"
fi

#primo checkpoint
echo "Primo checkpoint raggiunto"
if [ $quit == "table" ]; then exit; fi

#controllare se c'è il file guida, in caso di skip, verificare che sia nella cartella archivio
if [ ! -r $guidefile ]; then
	echo "Manca il file ort_guide.txt"; exit
fi

if [ ! -r $orglist ]; then
	echo "Manca il file org_list.txt"; exit
fi

if [ ! -r $table_def ]; then
	echo "Manca il file table_def.txt"; exit
fi

if [ $do_download == 1 ]; then
	#download genomi
	$download_cmd -table $table_def -file $orglist -type $downloadtype -outdir $rawgendir
	$download_cmd -table $table_def -file $orglist -type genomic -outdir $rawwholegendir
	chmod 666 $rawgendir/*
	chmod 666 $rawwholegendir/*

	#controllare bontà dei file (escludere eventuali .gz)
	for gen in $rawgendir/*; do
		fline=`head -1 $gen`
		if [ ${#fline} == 0 ]; then
			remove=`basename $gen`
			remove=${remove/.*/}
			grep "$remove" $guidefile -v > $tmpfile
			mv $tmpfile $guidefile
			grep "$remove" $orglist -v > $tmpfile
			mv $tmpfile $orglist
			taxid=`grep $remove $table_def | cut -f 2`
			echo "Salto $taxid: file non valido" >> $table_log
		fi
	done
else
	echo "Salto lo step di download"
fi

#primo checkpoint - fin qui tutto ok
echo "Secondo checkpoint raggiunto"
if [ $quit == "download" ]; then exit; fi


#effettuare i blast - solo quelli richiesti
#riformattare i genomi
if [ $do_reformat == 1 ]; then
	for gen in $rawgendir/*; do
		$reformat_db_cmd -db $gen > $refgendir/`basename $gen`
		if [ $seqtype == "dna" ]; then $translate_cmd -f $refgendir/`basename $gen` > $tragendir/`basename $gen`; fi
	done
	if [ $do_tblastn == 1 ]; then
		for gen in $rawwholegendir/*; do
			$reformat_genome_cmd -db $gen > $refwholegendir/`basename $gen`
		done
	fi
fi
	
#impostazioni preliminari
if [ $expect ]; then blastall_cmd="$blastall_cmd -e $expect"; tblastn_cmd="$tblastn_cmd -e $expect"; fi
	
#fare i tblastn
if [ $do_tblastn == 1 ]; then 
	while read line; do
		org1=`echo $line|awk '{print $1}'`
		org2=`echo $line|awk '{print $2}'`
		path1="$genpath/${org1:4}.${suffix}"
		path2="$refwholegendir/${org2:4}.fna"
		f1="$blasttmpdir/${org1:4}.${suffix}"
		f2="$blasttmpdir/${org2:4}.fna"
		tblastn="$tblastndir/tblastn_${org2:4}.fna_vs_${org1:4}.${suffix}.txt"
		if [ $seqtype == "protein" -a ! -r $tblastn ]; then
			cp $path1 $f1
			cp $path2 $f2
			formatdb -p T -i $f1
			formatdb -p F -i $f2
			echo "$tblastn_cmd -d $f2 -i $f1 -o $tblastn"; $tblastn_cmd -d $f2 -i $f1 -o $tblastn
			rm $blasttmpdir/*
		fi
	done < $guidefile
else
	echo "tblastn non eseguiti"
fi
	
#scorrere il file guida e fare i blast
if [ $do_blast == 1 ]; then
	while read line; do
		org1=`echo $line|awk '{print $1}'`
		org2=`echo $line|awk '{print $2}'`
		org3=`echo $line|awk '{print $3}'`
		echo $line
		path1="$genpath/${org1:4}.${suffix}"
		path2="$genpath/${org2:4}.${suffix}"
		path3="$genpath/${org3:4}.${suffix}"
		f1="$blasttmpdir/${org1:4}.${suffix}"
		f2="$blasttmpdir/${org2:4}.${suffix}"
		f3="$blasttmpdir/${org3:4}.${suffix}"
		blast1v2="$blastdir/blast_${org1:4}.${suffix}_vs_${org2:4}.${suffix}.txt"
		blast2v1="$blastdir/blast_${org2:4}.${suffix}_vs_${org1:4}.${suffix}.txt"
		blast1v3="$blastdir/blast_${org1:4}.${suffix}_vs_${org3:4}.${suffix}.txt"
		blast3v1="$blastdir/blast_${org3:4}.${suffix}_vs_${org1:4}.${suffix}.txt"
		blast2v3="$blastdir/blast_${org2:4}.${suffix}_vs_${org3:4}.${suffix}.txt"
		blast3v2="$blastdir/blast_${org3:4}.${suffix}_vs_${org2:4}.${suffix}.txt"
		cp $path1 $f1
		cp $path2 $f2
		cp $path3 $f3
		$formatdb_cmd -i $f1
		$formatdb_cmd -i $f2
		$formatdb_cmd -i $f3
		if [ ! -r $blast1v2 ]; then 
			echo "$blastall_cmd -d $f1 -i $f2 -o $blast1v2"
			$blastall_cmd -d $f1 -i $f2 -o $blast1v2
		fi
		if [ ! -r $blast2v1 ]; then
			echo "$blastall_cmd -d $f2 -i $f1 -o $blast2v1"
			$blastall_cmd -d $f2 -i $f1 -o $blast2v1
			fi
		if [ ! -r $blast1v3 ]; then
			echo "$blastall_cmd -d $f1 -i $f3 -o $blast1v3"
			$blastall_cmd -d $f1 -i $f3 -o $blast1v3
		fi
		if [ ! -r $blast3v1 ]; then
			echo "$blastall_cmd -d $f3 -i $f1 -o $blast3v1"
			$blastall_cmd -d $f3 -i $f1 -o $blast3v1
		fi
		if [ ! -r $blast2v3 ]; then
			echo "$blastall_cmd -d $f2 -i $f3 -o $blast2v3"
			$blastall_cmd -d $f2 -i $f3 -o $blast2v3
		fi
		if [ ! -r $blast3v2 ]; then
			echo "$blastall_cmd -d $f3 -i $f2 -o $blast3v2"
			$blastall_cmd -d $f3 -i $f2 -o $blast3v2
		fi
		rm $blasttmpdir/*
		echo ""
	done < $guidefile
else
	echo "Salto lo step di blast"
fi

echo "Terzo checkpoint raggiunto"
if [ $quit == "blast" ]; then exit; fi

#ortholuge
if [ $do_ortholuge == 1 ]; then
	while read line; do
		in1=`echo $line|awk '{print $1}'`
		in2=`echo $line|awk '{print $2}'`
		out=`echo $line|awk '{print $3}'`
		resrawdir="$ortrawdir/${in1}_${in2}/"
		resfile="$resrawdir/${in1}_${in2}__${out}.txt"
		if [ ! -d $resrawdir ]; then mkdir $resrawdir; fi
		if [ ! -r $resfile ]; then
			#controllare eventuali sovrapposizioni
			ingroup1="$refgendir/${in1:4}.${suffix}"
			ingroup2="$refgendir/${in2:4}.${suffix}"
			outgroup="$refgendir/${out:4}.${suffix}"
			blast1v2="$blastdir/blast_${in1:4}.${suffix}_vs_${in2:4}.${suffix}.txt"
			blast2v1="$blastdir/blast_${in2:4}.${suffix}_vs_${in1:4}.${suffix}.txt"
			blast1vO="$blastdir/blast_${in1:4}.${suffix}_vs_${out:4}.${suffix}.txt"
			blastOv1="$blastdir/blast_${out:4}.${suffix}_vs_${in1:4}.${suffix}.txt"
			blast2vO="$blastdir/blast_${in2:4}.${suffix}_vs_${out:4}.${suffix}.txt"
			blastOv2="$blastdir/blast_${out:4}.${suffix}_vs_${in2:4}.${suffix}.txt"
			if [ -r $blast1v2 ]; then cp $blast1v2 $orttmpdir/; else echo "Manca $blast1v2"; exit; fi
			if [ -r $blast2v1 ]; then cp $blast2v1 $orttmpdir/; else echo "Manca $blast2v1"; exit; fi
			if [ -r $blast1vO ]; then cp $blast1vO $orttmpdir/; else echo "Manca $blast1vO"; exit; fi
			if [ -r $blastOv1 ]; then cp $blastOv1 $orttmpdir/; else echo "Manca $blastOv1"; exit; fi
			if [ -r $blast2vO ]; then cp $blast2vO $orttmpdir/; else echo "Manca $blast2vO"; exit; fi
			if [ -r $blastOv2 ]; then cp $blastOv2 $orttmpdir/; else echo "Manca $blastOv2"; exit; fi
			$ortholuge_cmd --ingroup1 $ingroup1  --ingroup2 $ingroup2 --outgroup $outgroup
			echo "$ingroup1 $ingroup2 $outgroup"
			#mette anche le intestazioni
			echo -e "${in1:4}\t${in2:4}\t${out:4}\td_in1_in2\td_in1_out\td_in2_out\tr1\tr2\tr3" > $resfile
			cat $orttmpdir/triplet.out >> $resfile
			rm $orttmpdir/*
		fi
	done < $guidefile
else 
	echo "Salto lo step di ortholuge"
fi

#quarto checkpoint
echo "Quarto checkpoint raggiunto"
if [ $quit == "ortholuge" ]; then exit; fi

#inizializzare variabili che servono da qui in poi - bisogna usare i file di proteomi per le descrizioni
q=`cut -f1 $guidefile | uniq`
baseorg=$refgendir/${q:4}.$suffix
pad_cmd="$pad_cmd -g $baseorg"
raworg=$rawgendir/`basename $baseorg .$suffix`.${protsuf}
desc_cmd="$desc_cmd -g $raworg"
pairs_list=`while read line; do echo $line | awk '{print $1"_"$2}'; done < $guidefile | uniq`

#se l'opzione nofilt è attiva
if [ $nofilt == 1 ]; then
	echo "Filtro disattivato"
else
	echo "Filtro attivo"
fi

echo -e "Query\tIngroup\tMean\tStdev\tMedian\tMad" > $statfile

echo "Calcolo statistiche e filtro risultati"
for dir in $pairs_list; do
	#qui metto il calcolo delle statistiche
	dir=$ortrawdir/$dir
	filename=`basename $dir | awk -F_ '{print $1"_"$2"_"$3"_"$4"_"$5"_"$6"__"$4"_"$5"_"$6".txt"}'`
	filepath=$dir/$filename
	if [ $do_stat == 1 ]; then
		$stat_calc_cmd -infile $filepath
	fi
	if [ ! -d $ortfiltdir/`basename $dir` ]; then mkdir $ortfiltdir/` basename $dir`; fi
	if [ ! -d $unfiltdir/`basename $dir` ]; then mkdir $unfiltdir/` basename $dir`; fi
	for file in $dir/*; do
	if [ $nofilt == 1 ]; then
		cut -f 1,2,3 $file > $unfiltdir/`basename $dir`/`basename $file`
	else
		cut -f 1,2,3 $file > $unfiltdir/`basename $dir`/`basename $file`
		$ort_filter_cmd -infile $file > $ortfiltdir/`basename $dir`/`basename $file`
	fi
	done
done
#creata una cartella coi risultati filtrati e una coi risultati non filtrati

#se il filtro è attivo si procede con l'unire i file in entrambe le cartelle, altrimenti solo in quella dei non filtrati

#merging nella directory dei non filtrati - da fare sempre
echo "Unione outwalking"
for dir in $pairs_list; do
	dir=$unfiltdir/$dir
	dirdim=`ls -1 $dir| wc -l`
	if [ $dirdim == 1 ]; then 
		cp $dir/* $tmpunfiltdir/`basename ${dir}`.txt
	else
		out_first=$dir/`ls -1 $dir | head -1`
		out_merge_cmd="$out_merge_cmd -s $out_first"
		for out_second in `ls -1 $dir | tail -n +2`; do
			out_second=$dir/$out_second
			$out_merge_cmd -a $out_second > $tmpfile
			mv $tmpfile $out_first
		done
		cp $out_first $tmpunfiltdir/`basename ${dir}`.txt
	fi
done

#merging nella directory dei filtrati - da fare solo quando serve
if [ $nofilt == 0 ]; then
for dir in $pairs_list; do
	dir=$ortfiltdir/$dir
	dirdim=`ls -1 $dir| wc -l`
	if [ $dirdim == 1 ]; then 
		cp $dir/* $tmpfiltdir/`basename ${dir}`.txt
	else
		out_first=$dir/`ls -1 $dir | head -1`
		out_merge_cmd="$out_merge_cmd -s $out_first"
		for out_second in `ls -1 $dir | tail -n +2`; do
			out_second=$dir/$out_second
			$out_merge_cmd -a $out_second > $tmpfile
			mv $tmpfile $out_first
		done
		cp $out_first $tmpfiltdir/`basename ${dir}`.txt
	fi
done
fi

#filtro consenso: se è uguale a 0 bisogna passare entrambe le cartelle
echo "Filtro consenso"
if [ $nofilt == 0 ]; then
	for file in $tmpfiltdir/*; do
		$ccount_cmd -f $file > $tmpfile
		$cfilt_cmd -file $tmpfile -nofilt false > $file
	done
	for file in $tmpunfiltdir/*; do
		$ccount_cmd -f $file > $tmpfile
		$cfilt_cmd -file $tmpfile -nofilt true > $file
	done
else
	for file in $tmpunfiltdir/*; do
		$ccount_cmd -f $file > $tmpfile
		$cfilt_cmd -file $tmpfile -nofilt true > $file
	done
fi

#paddare e tagliare
for file in $tmpunfiltdir/*; do 
	$pad_cmd -f $file > $tmpfile
	cut -f 1,2 $tmpfile > $file
	rm $tmpfile
done
if [ $nofilt == 0 ]; then
	for file in $tmpfiltdir/*; do 
		$pad_cmd -f $file > $tmpfile
		cut -f 1,2 $tmpfile > $file
		rm $tmpfile
	done
fi

#unire l'inwalking
echo "Unione Inwalking"
in_first=$tmpunfiltdir/`ls -1 $tmpunfiltdir | head -1`
in_merge_cmd="$in_merge_cmd -s $in_first"
for in_second in `ls -1 $tmpunfiltdir | tail -n +2`; do
	in_second=$tmpunfiltdir/$in_second
	$in_merge_cmd -a $in_second > $tmpfile
	mv $tmpfile $in_first
done
cp $in_first $outunfiltfile

if [ $nofilt == 0 ]; then
	in_first=$tmpfiltdir/`ls -1 $tmpfiltdir | head -1`
	in_merge_cmd="$in_merge_cmd -s $in_first"
	for in_second in `ls -1 $tmpfiltdir | tail -n +2`; do
		in_second=$tmpfiltdir/$in_second
		$in_merge_cmd -a $in_second > $tmpfile
		mv $tmpfile $in_first
	done
	cp $in_first $outfiltfile
fi

#unire i file
if [ $nofilt == 0 ]; then
	$ort_merge_cmd -filtered $outfiltfile -unfiltered $outunfiltfile > $outfile
else
	cp $outunfiltfile $outfile
fi

#controllo statistiche
if [ $do_stat == 1 ]; then
	echo "Controllo statistiche"
	$stat_check_cmd -infile $outfile -statfile $statfile -ortdir $ortrawdir > $tmpfile
	mv $tmpfile $outfile
fi

#per i geni non trovati andare a vedere se c'è un risultato di blast e prendere il migliore
if [ $do_bbh == 1 ]; then
	echo "Ricerca bbh"
	$bbh_cmd -file $outfile > $tmpfile
	mv $tmpfile $outfile
else
	echo "Salto ricerca bth"
fi

if [ $do_bth == 1 ]; then
	echo "Ricerca bth"
	$bth_cmd -file $outfile -query $baseorg > $tmpfile
	mv $tmpfile $outfile
else
	echo "Salto ricerca bth"
fi

#rimuovere duplicati bbh
if [ -a $do_bbh == 1 ]; then
	$remdup_bbh_cmd -file $outfile > $tmpfile
	mv $tmpfile $outfile
fi

#aggiungere descrizioni
echo "Aggiunta descrizioni e nomi organismi"
if [ $seqtype == "protein" ]; then
	$desc_cmd -o $outfile > $tmpfile
	mv $tmpfile $outfile
else
	cp $in_first $outfile
fi

#aggiungere nomi organismi
$names_cmd -i $outfile > ${n_outfile}

#cleanup
echo "Cleanup"
rm -r $tmpdir
rm -r $orttmpdir
rm -r $ortfiltdir
rm -r $unfiltdir
rm -r $blasttmpdir
rm $outfiltfile $outunfiltfile

echo "Operazione completata"