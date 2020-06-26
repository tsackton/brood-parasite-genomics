#*_elem_lik is the likelihood, needs to be parsed to remove 0s
#*rate_postZ_2.txt is posterior probs

#make headers
head bp_out_run1/batch000_elem_lik.txt -n 1 > elem_lik.header
head bp_out_run1/batch000_rate_postZ_1.txt -n 1 > rate_postZ_1.header

#headers: No.     ID      loglik_NUll     loglik_RES      loglik_all      log_ratio       loglik_Max1     loglik_Max2     loglik_Max3
cat control_out/*_elem_lik.txt | awk 'BEGIN {OFS = "\t"} {if ($3 != 0) {print}}' | grep -v  "^No" > control_combined_elem_lik.temp 
cat bp_out/*_elem_lik.txt | awk 'BEGIN {OFS = "\t"} {if ($3 != 0) {print}}'  | grep -v  "^No" > bp_combined_elem_lik.temp 
cat bp_out/*_rate_postZ_1.txt | grep -v  "^No" >  bp_combined_postZ_1.temp  
cat control_out/*_rate_postZ_1.txt | grep -v  "^No" > control_combined_postZ_1.temp 

cat elem_lik.header control_combined_elem_lik.temp > control_combined_elem_lik.txt
cat elem_lik.header bp_combined_elem_lik.temp > bp_combined_elem_lik.txt
cat rate_postZ_1.header bp_combined_postZ_1.temp >  bp_combined_postZ_1.txt
cat rate_postZ_1.header control_combined_postZ_1.temp > control_combined_postZ_1.txt

gzip *.txt
rm *.temp
