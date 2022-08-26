sed -r '/^.+_[A-Z]+\t/d' 1-00000-of-00001 > temp_1-00000-of-00001
sleep 1
sed -r '/_/d' temp_1-00000-of-00001 > temp2_1-00000-of-00001
sleep 1
cat temp2_1-00000-of-00001 |awk -F '\t' '{print$1}' | grep -n "[0-9]" | awk -F ':' '{print$1}' > lines_to_be_removed.1D
sleep 1
sed 's%$%d%' lines_to_be_removed.1D | sed -f - temp2_1-00000-of-00001 > temp3_1-00000-of-00001
sleep 1
awk -F '\t' '{print$1}' temp3_1-00000-of-00001 |grep -n  "[[:alpha:]]" | awk -F ':' '{print$1}' > lines_not_to_be_removed.1D
sleep 1
awk 'NR==FNR{a[$0]=1;next}a[FNR]' lines_not_to_be_removed.1D temp3_1-00000-of-00001 > 1-00000-of-00001_cleaned
sleep 1

rm -f temp_1-00000-of-00001 temp2_1-00000-of-00001 temp3_1-00000-of-00001 lines_to_be_removed.1D lines_not_to_be_removed.1D


