setwd("/Users/tim/Projects/birds/brood_parasite/brood-parasite-genomics/04_protein_coding/branch_test/")
library(data.table)
library(qvalue)
library(tidyr)
library(dplyr)

#SERIOUSLY TRIMMED DOWN VERSION OF CODE FROM RATITES##

##ANALYSIS - FUNCTIONS##

#setup - load and clean data
prep_data <- function(file) {
  #load data -- dn
  read_line = paste0("gunzip -c ", file)
  dn<-fread(read_line, header=F, sep=",")
  names(dn)<-c("hog", "parent.node", "desc.node", "branch.id", "dn", "bp")
  return(dn)
}

#function to do vector projection
proj_vect <- function(genevec, sptree) {
  as.matrix(genevec) - sptree %*% t(sptree) %*% as.matrix(genevec)
}
#actually compute normalized stat
normalize_branch_stat <- function(DF, filter=TRUE) {
  dn.clean<-as.data.table(DF)
  #make unit vector
  dn.clean[,dn.length.bygene:=sqrt(sum(dn^2)), by=list(hog)]
  dn.clean$dn.unit.bygene=dn.clean$dn/dn.clean$dn.length.bygene
  #make average tree (average of all branches a tree appears on)
  dn.clean[,dn.average.tree:=mean(dn.unit.bygene, na.rm=T), by=list(branch.id)]
  #convert to unit vector (this will be different for each species tree configuration)
  dn.clean[,dn.unit.sptree:=dn.average.tree/sqrt(sum(dn.average.tree^2)), by=.(hog)]
  dn.clean[,dn.norm := proj_vect(dn.unit.bygene, dn.unit.sptree), by=.(hog)]
  if (filter) {
    branch_freqs<-as.data.frame(table(dn.clean$branch.id))
    dn.clean<-dn.clean[dn.clean$branch.id %in% branch_freqs$Var1[branch_freqs$Freq >= 500],]
  }
  return(dn.clean)
}

compute_pval <- function (x, groupvar) {
  if (inherits(try(ans<-wilcox.test(x ~ groupvar)$p.value,silent=TRUE),"try-error"))
    return(NA_real_)
  else
    return(ans)
}

#qc checks of distributions
make_qc_plots <- function(DF, file) {
  pdf(file=file)
  hist(DF$dn.norm, breaks=100)
  branch_freqs<-as.data.frame(table(dn.clean$branch.id))
  #normalization checks
  high_freq_branches = branch_freqs$Var1[branch_freqs$Freq > 5000]
  branch_key = unique(dn.clean[,c("branch.id","ratite","vl"), with=F])
  plot_branch_dists = data.frame(dn.norm=dn.clean$dn.norm[dn.clean$branch.id %in% high_freq_branches], branch.id=dn.clean$branch.id[dn.clean$branch.id %in% high_freq_branches])
  plot_branch_dists = merge(plot_branch_dists, branch_key, by.x="branch.id", by.y="branch.id")
  plot_branch_dists$color = "black"
  plot_branch_dists$color[plot_branch_dists$ratite]="red"
  plot_branch_dists$color[plot_branch_dists$vl]="blue"
  plot_branch_dists_colors = unique(plot_branch_dists[,c("branch.id", "color")])
  boxplot(plot_branch_dists$dn.norm2 ~ plot_branch_dists$branch.id, outline=F, col=plot_branch_dists_colors$color)
  dev.off()
}

get_dir <- function(x, groupby) {
  sign(cor(x=x, y=as.numeric(groupby), use="na.or.complete"))
}

## ANALYSIS STARTS HERE ###

dn<-prep_data(file="branches-parsed-ver2.csv.gz")
dn.default<-dn #no cleaning
dn.default<-normalize_branch_stat(dn.default)
dn.pval<-dn.default[,.(bp.p = compute_pval(dn.norm, bp)), by=hog]
dn.dir<-dn.default[,.(bp.dir = get_dir(dn.norm, bp)), by=hog]

length(dn.pval$hog)
summary(qvalue(dn.pval$bp.p))

dn.pval$q = p.adjust(dn.pval$bp.p, method="fdr")
write.table(dn.pval, file="bp_rate_test_pval.tsv", sep="\t", quote=F, row.names = F)
