#!/bin/bash

WORD2VEC="/home/giac/Documents/LAB/In_Corso/CORPORA/word2vec-master/word2vec"
FILETOPROCESS="$1"


echo "##############"
echo "Process $FILETOPROCESS"
file_to_save=`basename $FILETOPROCESS`
file_to_save=`echo $file_to_save | awk -F '.' '{print$1}'`
file_to_save=$file_to_save".dic"
echo "Saving dictionary file "$file_to_save

#echo $WORD2VEC" -train "$i" -save-vocab "$file_to_save
$WORD2VEC -train $FILETOPROCESS -min-count 40 -save-vocab $file_to_save
