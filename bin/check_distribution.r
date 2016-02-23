#!/usr/bin/R

options(warn = -1)

#acquire options
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-ssd-matrix") arg->ssd.mat.file
	if (opt == "-full-matrix") arg->full.mat.file
	if (opt == "-outfile") arg->outfile	
}

z.score<-function(tab,col="std",perc=0.95){
	out<-data.frame(AN=rownames(tab),std_zscore=NA,row.names="AN")
	val<-tab[,col]
	val<-val[val<=quantile(val,perc,na.rm=T)]
	std.mean<-mean(val,na.rm=T)
	std.std<-sd(val,na.rm=T)
	for (acc in rownames(tab)){
		sd.zscore<-(tab[acc,col]-std.mean)/std.std
		out[acc,"std_zscore"]<-sd.zscore
	}
	return(out)
}

ssd.matrix<-read.table(file=ssd.mat.file,header=TRUE,dec=".",na.strings="-",row.names=1)
full.matrix<-read.table(file=full.mat.file,header=TRUE,dec=".",na.strings="-",row.names=1)
full.dist<-data.frame(AN=rownames(full.matrix),mean=NA,std=NA,maxdev=NA,line_zscore=NA,std_zscore=NA,row.names="AN")
ssd.dist<-data.frame(AN=rownames(ssd.matrix),mean=NA,std=NA,maxdev=NA,line_zscore=NA,std_zscore=NA,row.names="AN")

for (acc in rownames(full.matrix)){
	ssd.line<-as.numeric(ssd.matrix[acc,])
	full.line<-as.numeric(full.matrix[acc,])
	
	ssd.mean<-mean(ssd.line,na.rm=TRUE)
	ssd.sd<-sd(ssd.line,na.rm=TRUE)
	ssd.max.dev<-max(c(ssd.mean-min(ssd.line,na.rm=TRUE),max(ssd.line,na.rm=TRUE)-ssd.mean))
	ssd.line.zscore<-ssd.max.dev/ssd.sd
	ssd.dist[acc,c("mean","std","maxdev","line_zscore")]<-c(ssd.mean,ssd.sd,ssd.max.dev,ssd.line.zscore)
		
	full.mean<-mean(full.line,na.rm=TRUE)
	full.sd<-sd(full.line,na.rm=TRUE)
	full.max.dev<-max(c(full.mean-min(full.line,na.rm=TRUE),max(full.line,na.rm=TRUE)-full.mean))
	full.line.zscore<-full.max.dev/full.sd
	full.dist[acc,c("mean","std","maxdev","line_zscore")]<-c(full.mean,full.sd,full.max.dev,full.line.zscore)
}
ssd.sd.zscores<-z.score(ssd.dist)
full.sd.zscores<-z.score(full.dist)
ssd.dist[,"std_zscore"]<-ssd.sd.zscores[,"std_zscore"]
full.dist[,"std_zscore"]<-full.sd.zscores[,"std_zscore"]
global.dist<-data.frame(AN=rownames(full.dist),ssd.dist[,"mean"],full.dist[,"mean"],ssd.dist[,"std"],full.dist[,"std"],ssd.dist[,"line_zscore"],full.dist[,"line_zscore"],ssd.dist[,"std_zscore"],full.dist[,"std_zscore"],row.names="AN")
names(global.dist)<-c("ssd_mean","full_mean","ssd_std","full_std","ssd_line_zscore","full_line_zscore","ssd_std_zscore","full_std_zscore")

cat(c(acc,names(global.dist)),sep="\t",file=outfile,append=FALSE)
cat("\n",file=outfile,append=TRUE)
for (acc in rownames(global.dist)){
	cat(c(acc,as.character(global.dist[acc,])),sep="\t",file=outfile,append=TRUE)
	cat("\n",file=outfile,append=TRUE)
}