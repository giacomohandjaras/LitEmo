clear all
close all

SANETOOLBOX='../../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);

hamilton=readtable('diachronic/disps_allyears.txt','Delimiter',',');
hamilton_dictionary=table2cell(hamilton(:,1));
hamilton_data=table2array(hamilton(1:end,2:end));
hamilton_ranks=tiedrank(hamilton_data);
hamilton_score=nanmean(hamilton_ranks,2);
[hamilton_score_sorted,hamilton_score_indx]=sort(hamilton_score,'ascend');
hamilton_dictionary_sorted=hamilton_dictionary(hamilton_score_indx);
SNLP_saveWords('hamilton_top10.txt',hamilton_dictionary_sorted(1:1000));

hamilton_top10=SNLP_loadWords('hamilton_top10.txt');
others=SNLP_loadWords('external_words.txt');

diachronic_words=cat(1,hamilton_top10,others);
diachronic_words=lower(diachronic_words);
diachronic_words=SNLP_removePunctuation(diachronic_words);
diachronic_words=SNLP_removeSpaces(diachronic_words);
diachronic_words=unique(diachronic_words);

SNLP_saveWords('diachronic_eng.txt',diachronic_words);
