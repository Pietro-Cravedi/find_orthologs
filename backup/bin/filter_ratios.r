#!/usr/bin/R

#sostituisce il programma che filtra i risultati di ortholuge
#c1, c2 e c3 sono i coefficienti con cui moltiplicare le stdev
#output a schermo

options(warn = -1)

#acquisire opzioni
c1<-1.5
c2<-1.5
c3<-3
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-infile") arg->infile
	if (opt == "-c1") arg->c1
	if (opt == "-c2") arg->c2
	if (opt == "-c3") arg->c3
}

c1<-as.numeric(c1)
c2<-as.numeric(c2)
c3<-as.numeric(c3)

tab<-read.table(file=infile,header=TRUE,dec=".")
r1<-tab$r1[tab$r1<=as.numeric(quantile(tab$r1,0.99))]
r2<-tab$r2[tab$r2<=as.numeric(quantile(tab$r2,0.99))]
f5<-as.numeric(quantile(tab$r3,0.05))
l5<-as.numeric(quantile(tab$r3,0.95))
r3<-tab$r3[tab$r3>=f5 & tab$r3<=l5]
m1<-mean(r1)
m2<-mean(r2)
m3<-mean(r3)
s1<-sd(r1)
s2<-sd(r2)
s3<-sd(r3)
l.r1<-m1+(c1*s1)
l.r2<-m2+(c2*s2)
l.r3l<-m3-(c3*s3)
l.r3u<-m3+(c3*s3)
cat(names(tab)[1:3],sep="\t")
cat("\n")
outtab<-as.matrix(tab[tab$r1<l.r1 & tab$r2<l.r2 & tab$r3>l.r3l & tab$r3<l.r3u,])
if (names(tab)[3]!=paste0(c(names(tab)[2],".1"),collapse="")) {
	for (i in 1:nrow(outtab)){
		cat(outtab[i,1:3],sep="\t")
		cat("\n")
	}
}