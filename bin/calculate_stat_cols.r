#!/usr/bin/R

options(warn = -1)

#fetch options
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-infile") arg->infile
	if (opt == "-outfile") arg->outfile
}

#calculate means
tab<-read.table(file=infile,header=TRUE,dec=".")
media<-mean(tab[,4])
stdev<-sd(tab[,4])
mediana<-median(tab[,4])
med.abs.dev<-mad(tab[,4])

#output
cat(c(names(tab)[1:2],media,stdev,mediana,med.abs.dev),sep="\t",file=outfile,append=TRUE)
cat("\n",file=outfile,append=TRUE)