awk '
    FNR==1 && NR!=1 { while (/^<header>/) getline; }
    1 {print}
' *_${1}.txt > ${1}_combined.txt 
