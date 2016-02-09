#!/usr/bin/R

#dato un albero estrae tutte le terne query ingroup outgroup con query specificata

library(ape)
options(warn = -1)
outfile<-"terne.txt"

#acquisire opzioni
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-tree") arg->infile
	if (opt == "-query") arg->query
	if (opt == "-outfile") arg->outfile
	if (opt == "-outlist") arg->outlist
}

#convertire in stringa
query<-as.vector(query,"character")


#definire getDescendants
getDescendants<-function(tree,node,curr=NULL){
  if(is.null(curr)) curr<-vector()
  daughters<-tree$edge[which(tree$edge[,1]==node),2]
  curr<-c(curr,daughters)
  w<-which(daughters>=length(tree$tip))
  if(length(w)>0) for(i in 1:length(w)) 
    curr<-getDescendants(tree,daughters[w[i]],curr)
  return(curr)
}

#ottenere gli organismi dell'albero
tree<-read.tree(file=infile)				#apri albero
max.org<-length(tree$tip.label) 			#max.org=numero di organismi
org.full<-1:max.org							#indici degli organismi
cat("",file=outfile) 						#inizializza come file vuoto il file di output
cat("",file=outlist) 						#inizializza come file vuoto il file con la lista degli organismi

for (i in 1:max.org){
	org<-tree$tip.label[i]
	num<-max.org-i+1
	counter<-sprintf("%03d",num)
	numbered<-paste(c(counter,org),collapse="_")
	cat(c(numbered,"\n"),file=outlist,append=TRUE)
	if (tree$tip.label[i] == query) {query<-numbered}
	tree$tip.label[i]<-numbered
}

for (org.single in tree$tip.label) if (org.single != query) {	#prendi uno alla volta gli elementi di org.full.lab != da query
	int.node<-getMRCA(tree,c(query,org.single))				#ottenere subset di ingroups
	org.ingroup<-getDescendants(tree,int.node)				#
	org.ingroup<-org.ingroup[org.ingroup<=max.org]			#
	org.outgroup<-org.full
	for (ingroup in org.ingroup){ 							#prendere gli ingroups uno alla volta
		org.outgroup<-org.outgroup[org.outgroup!=ingroup] 	#elimina via via gli ingroup dal set completo
	}
	org.outgroup<-tree$tip.label[org.outgroup] 				#converti in etichette
	#mettere la tripletta self - query-ingroup-ingroup - per ora tenere in commento
	cat(c(query,org.single,org.single),file=outfile,append=TRUE,sep="\t");cat("\n",file=outfile,append=TRUE)
	#prendere uno alla volta gli organismi del set di outgroup, controllare che non ci siano duplicati, aggiungere la terna al file
	for (out in org.outgroup) if (query != out & org.single != out) {cat(c(query,org.single,out),file=outfile,append=TRUE,sep="\t");cat("\n",file=outfile,append=TRUE)}
}