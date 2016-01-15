#!/usr/bin/R

library(ape)
options(warn = -1)

#acquisire opzioni
options = commandArgs()[6:length(commandArgs())]
num=length(options)
if (num == 0 | num%%2 != 0) q()
for (i in 1:(length(options)-1)){
	opt=options[i]
	arg=options[i+1]
	if (opt == "-tree") arg->infile
	if (opt == "-query") arg->query
	if (opt == "-outgroup") arg->outgroup
	if (opt == "-first") arg->first.org
	if (opt == "-last") arg->last.org
	if (opt == "-outfile") arg->outfile
}

#convertire in stringhe
first.org<-as.vector(first.org,"character")
last.org<-as.vector(last.org,"character")
query<-as.vector(query,"character")
if (exists("outgroup")) outgroup<-as.vector(outgroup,"character")
tree<-read.tree(file=infile)

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

#ottenre gli indici degli input
input<-c(first.org,last.org)
index.lim<-which(tree$tip.label==input[1])
index.lim<-c(index.lim,which(tree$tip.label==input[2]))
index.lim<-sort(index.lim)
index.query<-which(tree$tip.label==query)
if (exists("outgroup")) index.outgroup<-which(tree$tip.label==outgroup)

#ottenere la lista di foglie da tagliare
all.orgs<-getDescendants(tree,length(tree$tip.label)+1)
max.orgs<-length(tree$tip.label)
all.orgs<-all.orgs[all.orgs<=max.orgs]
to.remove<-all.orgs[(all.orgs<index.lim[1]|all.orgs>index.lim[2])&all.orgs!=index.query]
if (exists("index.outgroup")) to.remove<-to.remove[to.remove!=index.outgroup]

edit.tree<-drop.tip(tree,to.remove)
#scrivere file di output
write.tree(edit.tree,file=outfile)