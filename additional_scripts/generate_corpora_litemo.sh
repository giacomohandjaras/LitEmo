#!/bin/bash

echo "Building the corpus...."

books_preprocessed="../../AUTHORS_ENG/"
sorting_order="../../id_authors_curriculum_learning_v20220112.txt"
suffix_book=".txt"
corpora_to_be_saved_default='../../corpora_litemo_curriculum_learning_v20220112.txt'


corpora_to_be_saved=$1
if [ -z "$1" ]; then
corpora_to_be_saved=$corpora_to_be_saved_default
fi
echo "Saving corpus in: $corpora_to_be_saved"


if [ -f $corpora_to_be_saved ];then
echo "File already existing, interrupting..."
exit 1
else
touch "$corpora_to_be_saved"
fi

echo "Wait..."

while read INDEX; do
	libro=$books_preprocessed$INDEX$suffix_book
	echo "Process document: $libro"
	cat $libro >> $corpora_to_be_saved
done < "$sorting_order"
