VERSION=$1
cd bp_out
../concat_output.sh elem_lik
mv elem_lik_combined.txt ../elem_lik_combined_BP_${VERSION}.txt
../concat_output.sh  rate_postZ_M2
mv rate_postZ_M2_combined.txt ../rate_postZ_M2_combined_BP_${VERSION}.txt
cd ..
cd control_out
../concat_output.sh elem_lik
mv elem_lik_combined.txt ../elem_lik_combined_CONTROL_${VERSION}.txt
../concat_output.sh  rate_postZ_M2
mv rate_postZ_M2_combined.txt ../rate_postZ_M2_combined_CONTROL_${VERSION}.txt
cd ..
