#!/usr/bin/R

#calcola z-score dal file output di calculate stat rows
#z-score: data la distribuzione delle sd delle medie delle righe, è di quante sd di quella distribuzione la sd di riga differisce dalla media delle sd
#da usare sul file con rimossi NA e NaN

options(warn = -1)
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
        opt=options[i]
        arg=options[i+1]
        if (opt == "-infile") arg->infile
}
cat(c(names(infile),"z-score"),sep="\t")
tab<-read.table(file=infile,dec=".",header=TRUE)
mean.stdev<-mean(tab$stdev)
dev.stdev<-sd(tab$stdev)
for (i in 1:nrow(tab)){
        z.score<-(tab$stdev[i]-mean.stdev)/dev.stdev
        cat(c(tab[i,],z.score),sep"\t")
}
