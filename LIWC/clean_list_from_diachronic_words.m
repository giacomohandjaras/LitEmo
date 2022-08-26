clear all
close all

SANETOOLBOX='../../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);


words_of_interest=SNLP_loadWords('LIWC2015_English_neg.txt');
words_to_exclude=SNLP_loadWords([SANETOOLBOX,'/diachronic_eng.txt']);

words_to_remove=zeros(numel(words_of_interest),1);

for w=1:numel(words_of_interest)
pos=regexp(words_of_interest{w},"\*");
if pos>0 %%%we have found a stemmed word
[word]=strsplit(words_of_interest{w},'*');
word_search=strcat('^',word(1,1),' *');
word_mask=regexp(words_to_exclude,word_search);
word_mask_notempty = ~cellfun(@isempty, word_mask);
word_found=words_to_exclude(find(word_mask_notempty));
if numel(word_found)>0
%word_found
words_to_remove(w)=1;
end
else
word_mask=strcmp(words_to_exclude,words_of_interest{w});
word_found=words_to_exclude(find(word_mask));
if numel(word_found)>0
%word_found
words_to_remove(w)=1;
end
end
end


words_of_interest_selected=words_of_interest(find(words_to_remove==0));
SNLP_saveWords('LIWC2015_English_neg_nodiachronic.txt',words_of_interest_selected);

