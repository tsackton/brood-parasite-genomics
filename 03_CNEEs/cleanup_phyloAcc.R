#check new runs

library(tidyverse)

cols<-c("num", "cnee", "lik_null", "lik_acc", "lik_full", "logBF1", "logBF2", "lik_maxM0", "lik_maxM1", "lik_maxM2")
bp_lik <- read_delim(file="/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/elem_lik_combined_BP_v6_clean.txt", col_names=cols, delim="\t")
ct_lik <- read_delim(file="/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/elem_lik_combined_CONTROL_v6_clean.txt", col_names=cols, delim="\t")

bed<-read_delim("/Users/tim/Projects/birds/brood_parasite/local_data/taeGut1_final_merged_CNEEs_named.bed", col_names = c("chr", "start", "end", "name"), delim="\t")

all_lik <- bp_lik %>% 
  full_join(ct_lik, by=c("cnee" = "cnee", "num" = "num"), suffix=c(".bp", ".ct")) %>%
  full_join(bed, by=c("cnee" = "name")) %>% mutate(length = end-start, num = as.character(num))

table(all_lik$lik_null.bp == 0, all_lik$lik_null.ct == 0)

#remove those < 50 bp in length

all_lik <- all_lik %>% filter(length >= 50, lik_null.bp != 0, lik_null.ct != 0)

ggplot(all_lik, aes(x=lik_null.bp, y=lik_null.ct)) + geom_point(alpha=0.1)
ggplot(all_lik, aes(x=lik_full.bp, y=lik_full.ct)) + geom_point(alpha=0.1)
ggplot(all_lik, aes(x=lik_acc.bp, y=lik_acc.ct)) + geom_point(alpha=0.1)
ggplot(all_lik, aes(x=logBF1.bp, y=logBF1.ct)) + geom_point(alpha=0.1)
ggplot(all_lik, aes(x=logBF2.bp, y=logBF2.ct)) + geom_point(alpha=0.1)

write_tsv(all_lik, "/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/all_element_lik.txt")

#get M2 results

all_cnee <- all_lik %>% select(num, cnee)

cols<-scan("/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/postZ_BP_header", character(), quote="")
cols[1] = "cnee_num"
bpZ <- read_delim(file="/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/rate_postZ_M2_combined_BP_v6_clean.txt", col_names=cols, delim="\t") %>% 
  mutate(cnee_num = as.character(cnee_num)) %>%
  right_join(all_cnee, by=c("cnee_num" = "num")) 
bpZ %>% write_tsv("/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/bp_Zmat.txt")
ctZ <- read_delim(file="/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/rate_postZ_M2_combined_CONTROL_v6_clean.txt", col_names=cols, delim="\t") %>% 
  mutate(cnee_num = as.character(cnee_num)) %>%
  right_join(all_cnee, by=c("cnee_num" = "num"))
ctZ %>% write_tsv("/Users/tim/Projects/birds/brood_parasite/local_data/20200622_v6/ct_Zmat.txt")


