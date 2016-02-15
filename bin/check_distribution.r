#!/usr/bin/R

#calcola di quante stdev gli ssd deviano dalla media

options(warn = -1)

#acquisire opzioni
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-ssd-matrix") arg->ssd.mat.file
	if (opt == "-full-matrix") arg->full.mat.file
	
	
}

ssd.matrix<-read.table(file=ssd.mat.file,header=TRUE,dec=".",na.strings="-",row.names=1)
full.matrix<-read.table(file=full.mat.file,header=TRUE,dec=".",na.strings="-",row.names=1)
full.dist<-data.frame(AN=rownames(full.matrix),mean=NA,std=NA,maxdev=NA,row.names="AN")
ssd.dist<-data.frame(AN=rownames(ssd.matrix),mean=NA,std=NA,maxdev=NA,row.names="AN")
full.zscores<-full.matrix
full.zscores[1:nrow(full.zscores),1:ncol(full.zscores)]<-NA
ssd.zscores<-ssd.matrix
ssd.zscores[1:nrow(ssd.zscores),1:ncol(ssd.zscores)]<-NA

for (acc in rownames(ssd.matrix)){
	ssd.line<-as.numeric(ssd.matrix[acc,])
	full.line<-as.numeric(full.matrix[acc,])
	
	ssd.mean<-mean(ssd.line,na.rm=TRUE)
	ssd.sd<-sd(ssd.line,na.rm=TRUE)
	ssd.max.dev<-max(c(ssd.mean-min(ssd.line,na.rm=TRUE),max(ssd.line,na.rm=TRUE)-ssd.mean))
	ssd.dist[acc,c("mean","std","maxdev")]<-c(ssd.mean,ssd.sd,ssd.max.dev)
	for (i in 1:length(ssd.line)){
		zscore<-(ssd.line[i]-ssd.mean)/ssd.sd
		ssd.zscores[acc,i]<-zscore
	}
	
	full.mean<-mean(full.line,na.rm=TRUE)
	full.sd<-sd(full.line,na.rm=TRUE)
	full.max.dev<-max(c(full.mean-min(full.line,na.rm=TRUE),max(full.line,na.rm=TRUE)-full.mean))
	full.dist[acc,c("mean","std","maxdev")]<-c(full.mean,full.sd,full.max.dev)
	for (i in 1:length(full.line)){
		zscore<-(full.line[i]-full.mean)/full.sd
		full.zscores[acc,i]<-zscore
	}
}

