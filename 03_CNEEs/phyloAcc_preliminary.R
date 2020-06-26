#preliminary CNEE analysis for brood parasite project
library(tidyverse)
library(ggthemes)
setwd("/Users/tim/Projects/birds/brood_parasite/local_data")
source("ggmm.R")

#functions
trunc_to_one <- function(x) {
  ifelse(x > 1, 1, x)
}

discretize <- function(x, cutoff = 0.90) {
  ifelse(x >= cutoff, 1, 0)
}

#read in data and clean up
likBP<-read_tsv("new_runs_20200127/elem_lik_combined_BP_good.txt", 
  col_names = c("key", "cnee", "loglik_Null",	"loglik_Acc",	"loglik_Full", "logBF1", "logBF2", "loglik_Max_M0",	
                "loglik_Max_M1",	"loglik_Max_M2")) %>% 
  arrange(loglik_Full) %>%
  distinct(cnee, .keep_all=TRUE) %>%
  mutate(bf1 = loglik_Acc - loglik_Null, bf2 = loglik_Acc - loglik_Full) %>%
  rename(loglik.null = loglik_Null, loglik.target = loglik_Acc, loglik.full = loglik_Full)

likCT<-read_tsv("new_runs_20200127/elem_lik_combined_CONTROL_good.txt", 
                col_names = c("key", "cnee", "loglik_Null",	"loglik_Acc",	"loglik_Full", "logBF1", "logBF2", "loglik_Max_M0",	
                              "loglik_Max_M1",	"loglik_Max_M2")) %>% 
  arrange(loglik_Full) %>%
  distinct(cnee, .keep_all=TRUE) %>%
  mutate(bf1 = loglik_Acc - loglik_Null, bf2 = loglik_Acc - loglik_Full) %>%
  rename(loglik.null = loglik_Null, loglik.target = loglik_Acc, loglik.full = loglik_Full)

#compare to old run
#lik_orig<-read.table("Combined_elem_lik_061.txt", header=T, stringsAsFactors = F) %>% tbl_df %>%
#  mutate(bf1 = loglik_RES - loglik_NUll, bf2 = loglik_RES - loglik_all) %>%
#  dplyr::select(cnee = ID, bf1, bf2, loglik.null = loglik_NUll, loglik.ratite = loglik_RES, loglik.full = #loglik_all)
#lik_comp <- inner_join(lik, lik_orig, by=c("cnee" = "cnee"), suffix = c(".new", ".orig"))
#ggplot(lik_comp, aes(x=bf1.new, y=bf1.orig)) + stat_binhex(bins=100)
#ggplot(lik_comp, aes(x=bf2.new, y=bf2.orig)) + stat_binhex(bins=100)
#lik_comp %>% filter(bf2.new <= 0, bf2.orig > 10)

zpostBP<-read_tsv("bp_combined_postZ_1.txt", col_types = cols(.default = "d"))
zpostCT<-read_tsv("control_combined_postZ_1.txt", col_types = cols(.default = "d"))

#posterior prob acceleration
postaccBP<-zpostBP %>% select(contains("_3"))
postaccBP$key = zpostBP$No.
postaccBP$acc_rate = zpostBP$n_rate
postaccBP$cons_rate = zpostBP$c_rate

#posterior prob acceleration
postaccCT<-zpostCT %>% select(contains("_3"))
postaccCT$key = zpostCT$No.
postaccCT$acc_rate = zpostCT$n_rate
postaccCT$cons_rate = zpostCT$c_rate

#convert to 1/0  matrix
postaccmatBP <- postaccBP[1:33]
postaccmatBP[postaccmatBP >= 0.95] = 1
postaccmatBP[postaccmatBP < 0.95] = 0
postaccmatBP$key = postaccBP$key

postaccmatCT <- postaccCT[1:33]
postaccmatCT[postaccmatCT >= 0.95] = 1
postaccmatCT[postaccmatCT < 0.95] = 0
postaccmatCT$key = postaccCT$key

#fix names
names(postaccBP) = gsub("-", "_", names(postaccBP))
names(postaccCT) = gsub("-", "_", names(postaccCT))


#compute expected number of losses for each parasite clade:
postaccBP <- postaccBP %>% mutate(cuckoo = (cucCan_3 - calAnn_cucCan_3)) %>%
  mutate(cowbird = molAte_3 - molAte_agePho_3) %>%
  mutate(vidua = vidMac_3 - vidMac_taeGut1_3) %>%
  mutate(loss = cowbird + cuckoo + vidua) %>%
  mutate(loss_disc = discretize(cowbird)+discretize(cuckoo)+discretize(vidua))

postaccCT <- postaccCT %>% mutate(hummingbird = (calAnn_3 - calAnn_cucCan_3)) %>%
  mutate(blackbird = agePho_3 - molAte_agePho_3) %>%
  mutate(zebrafinch = taeGut1_3 - vidMac_taeGut1_3) %>%
  mutate(loss = hummingbird + blackbird + zebrafinch) %>%
  mutate(loss_disc = discretize(hummingbird)+discretize(blackbird)+discretize(zebrafinch))

#make analysis dataset
cneeBP<-inner_join(postaccBP, likBP, by=c("key" = "key")) %>% 
  filter(cons_rate <= 0.60) %>% ungroup
cneeCT<-inner_join(postaccCT, likCT, by=c("key" = "key")) %>% 
  filter(cons_rate <= 0.60) %>% ungroup

cnee <- cneeCT %>% select(hummingbird, blackbird, zebrafinch, loss, loss_disc, cnee, loglik.target, bf1, bf2) %>% 
  inner_join(cneeBP, by=c("cnee" = "cnee"), suffix=c(".ct", ".bp"))

#add bed info
cneeBED <- read_tsv("taeGut1_final_merged_CNEEs_named.bed", col_names = c("chr", "start", "end", "cnee"))
cnee <- inner_join(cnee, cneeBED, by=c("cnee" = "cnee"))

#write out
write_csv(cnee, "cnees_analysis.csv")

cnee <- cnee %>% mutate(bpAccel = bf1.bp > 10, bpSpec = bf1.bp > 10 & bf2.bp > 1, bpConv = bpSpec & loss.bp >= 2) %>%
  mutate(ctlAccel = bf1.ct > 10, ctlSpec = bf1.ct > 10 & bf2.ct > 1, ctlConv = ctlSpec & loss.ct >= 2)


#basic test
cnee %>% filter(ctlSpec == 1) %>% count(ctlConv)
cnee %>% filter(bpSpec == 1) %>% count(bpConv)
fisher.test(matrix(c(18,697,36,3554), nrow=2))

#fisher.test(matrix(c(18,697,36,3554), nrow=2))
#Fisher's Exact Test for Count Data

#data:  matrix(c(18, 697, 36, 3554), nrow = 2)
#p-value = 0.002516
#alternative hypothesis: true odds ratio is not equal to 1
#95 percent confidence interval:
#1.354268 4.637668
#sample estimates:
#odds ratio 
#2.548898 

#make plot
cnee %>% filter(bpSpec | ctlSpec) %>% mutate(target = ifelse(bpSpec, "brood_parasite", "control")) %>% 
  mutate(loss = ifelse(bpSpec, loss.bp, loss.ct)) %>% select(target,loss) %>% 
  ggplot(aes(x=loss, y=..scaled.., color=target)) + theme_few() + geom_density(adjust=1/2, size=1.5) + 
  xlab("Posterior estimated number of independent losses") +
  ylab("Normalized density") + labs(color = "Target lineages")

#not sure I like this, try odds ratios?
cnee %>% filter(bpSpec | ctlSpec) %>% mutate(target = ifelse(bpSpec, "brood_parasite", "control")) %>% 
  mutate(loss = ifelse(bpSpec, loss.bp, loss.ct)) %>% select(target,loss) %>% 
  mutate(loss = ifelse(loss >= 1.5, "multiple", "single")) %>% ggmm(target,loss, add_text="n") + theme_tufte() + scale_fill_pander()

###using code from immune paper
########
#Calculate numbers of genes overlapping at q<0.1 - q<-0.0001 and Fisher's exact tests for significance.
cutoffs <- c(1,1.5,2)
comp_cutoff <- matrix(nrow=3,ncol=9)
cnee_conv <- cnee %>% filter(bpSpec | ctlSpec) %>% mutate(target = ifelse(bpSpec, "brood_parasite", "control")) %>% 
  mutate(loss = ifelse(bpSpec, loss.bp, loss.ct)) %>% select(target,loss)

for (i in 1:length(cutoffs)){
  
  comp_cutoff[i,1] <- cutoffs[i]
  
  #Fisher's exact tests
  comp_cutoff[i,2:9] <- cnee_conv %>% 
    mutate(loss_cat = ifelse(loss >= cutoffs[i], "multiple", "single")) %>% 
    with(., table(target, loss_cat)) %>% fisher.test %>% unlist
  
  colnames(comp_cutoff) <- c("cutoff","p.value","conf.int1","conf.int2","estimated.odds.ratio","null.value.odds.ratio","alternative","method","data.name")
}

#Clean up, select relevant columns
comp_cutoff_clean <- comp_cutoff %>%
  as.tibble %>%
  mutate(p.value=round(as.numeric(p.value),digits = 4),odds.ratio=round(as.numeric(estimated.odds.ratio),digits=2), conf.lower=round(as.numeric(conf.int1),digits=3), conf.upper=round(as.numeric(conf.int2),digits=3)) %>%
  dplyr::select(cutoff,odds.ratio,conf.lower,conf.upper,p.value)

#Create vector of asterisks to include in plots:
comp_cutoff_clean <- comp_cutoff_clean %>%
  mutate(sig = case_when(
    is.na(p.value) ~ "",
    p.value > 0.05 ~ "",
    p.value <= 0.05 & p.value > 0.01 ~ "*",
    p.value <= 0.01 & p.value > 0.001 ~ "**",
    p.value <= 0.001 ~ "***"
  ))

#Plot odds ratio plot alone
comp_cutoff_clean %>%
  ggplot(aes(factor(cutoff,levels=c("1", "1.5", "2")),odds.ratio)) +
  geom_point(size=8,position=position_dodge(width=0.9),col="#DF5C24") +
  geom_linerange(aes(factor(cutoff,levels=c("1", "1.5", "2")),ymin=conf.lower,ymax=conf.upper),size=2,col="#DF5C24") +
  geom_hline(aes(yintercept = 1),size=2,linetype="dashed",col="black") +
  scale_x_discrete(labels=c("1", "1.5", "2")) +
  xlab("cutoff") +
  ylab("odds ratio") +
  ylim(0,5) +
  theme_few() + theme(axis.title = element_text(size=24), axis.text = element_text(size=18))

##

cnee %>% filter(bpSpec | ctlSpec) %>% mutate(target = ifelse(bpSpec, "brood_parasite", "control")) %>% 
  mutate(loss = ifelse(bpSpec, loss.bp, loss.ct)) %>% select(target,loss) %>% 
  mutate(loss = ifelse(loss >= 2, "multiple", "single")) %>% ggmm(target,loss, add_text="n") + theme_tufte()

#old code below


cnee %>% filter(bpSpec, vidua > 0.5, cowbird > 0.5, cuckoo > 0.5) %>% select(cnee, acc_rate:loss_disc.bp, bf1.bp:ctlConv)

#just look at tips
tips <- postaccmatBP %>% select(galGal_3:taeGut1_3) %>% mutate(bp = cucCan_3 + vidMac_3 + molAte_3, ct = taeGut1_3 + agePho_3 + calAnn_3) %>%
  mutate(rand = serCan_3 + parMaj_3 + pasDom_3) %>%
  mutate(total = rowSums(.[1:17]))
tips %>% filter(total==bp) %>% count(bp)
tips %>% filter(total==ct) %>% count(ct)
tips %>% filter(total==rand) %>% count(rand)

colSums(tips[1:17])
ggplot(tips, aes(x=total)) + geom_histogram(bins=20)
