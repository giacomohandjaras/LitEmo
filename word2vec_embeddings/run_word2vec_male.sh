../EmoCat/gridsearch/word2vec-master/word2vec -train corpora_litemo_male_curriculum_learning_v20211222.txt -read-vocab corpora_litemo_curriculum_learning_v20211222.dic -output corpora_litemo_male_a05s512w5s1E03_v20211222.bin  -alpha 0.05 -threads 12 -iter 10 -size 512 -window 5 -sample 1e-3 -negative 0 -hs 1 -binary 0 -cbow 0
