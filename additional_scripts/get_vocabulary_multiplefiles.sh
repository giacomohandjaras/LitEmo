#!/bin/bash

WORD2VEC="/home/giac/Documents/LAB/In_Corso/CORPORA/word2vec-master/word2vec"
DIRTOPROCESS="../AUTHORS_ENG"
FILETOPROCESS="*.txt"

DATA=$DIRTOPROCESS"/"$FILETOPROCESS;

for i in $DATA; do
echo "##############"
echo "Process $i"
file_to_save=`basename $i`
file_to_save=`echo $file_to_save | awk -F '.' '{print$1}'`
file_to_save=$DIRTOPROCESS"/"$file_to_save".dic"
echo "Saving dictionary "$file_to_save

#echo $WORD2VEC" -train "$i" -save-vocab "$file_to_save
$WORD2VEC -train $i -min-count 0 -save-vocab $file_to_save

done
