#!/usr/bin/R

#calcola la media lungo le righe

options(warn = -1)

#acquisire opzioni
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-infile") arg->infile
	if (opt == "-outfile") arg->outfile
}

#calcolo statistiche
tab<-read.table(file=infile,header=TRUE,dec=".",na.strings="-")
mat<-as.matrix(tab)
cat(c(names(tab)[1],"media","stdev"),file=outfile,sep="\t",append=FALSE)
cat("\n",file=outfile,append=TRUE)
for (i in 1:nrow(mat)){
	as.numeric(mat[i,2:ncol(mat)])->linea
	media<-mean(linea,na.rm=TRUE)
	stdev<-sd(linea,na.rm=TRUE)
	if (media != "NaN"){
		cat(c(mat[i,1],media,stdev),file=outfile,sep="\t",append=TRUE)
		cat("\n",file=outfile,append=TRUE)
	}
}