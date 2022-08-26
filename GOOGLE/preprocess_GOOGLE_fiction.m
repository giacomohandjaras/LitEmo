clear all
clc

SANETOOLBOX='../../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);

dic=SNLP_loadWords('1-00000-of-00001_cleaned.dic');
dictionary=string(dic(1:end,1));
occurrences=cellfun(@str2num, dic(1:end,2));
clear dic

[occurrences_sorted,occurrences_index]=sort(occurrences,'descend');
dictionary=dictionary(occurrences_index);
occurrences=occurrences_sorted;
clear occurrences_sorted


%%%%Clean up google similarly to our pipeline
dictionary=lower(dictionary);
dictionary_cleaned=SNLP_removePunctuation(dictionary);


dictionary_final={};
occurrences_final=[];
dictionary_pos=1;

for w=1:numel(dictionary_cleaned)
current_word=dictionary_cleaned{w};
current_words=strsplit(current_word);
if numel(current_words)>1

for j=1:numel(current_words)
if(isempty(current_words{j})==0)
dictionary_final{dictionary_pos,1}=current_words{j};
occurrences_final(dictionary_pos,1)=occurrences(w);
dictionary_pos=dictionary_pos+1;
end
end
else
dictionary_final{dictionary_pos,1}=current_word;
occurrences_final(dictionary_pos,1)=occurrences(w);
dictionary_pos=dictionary_pos+1;
end
end

clear dictionary dictionary_cleaned occurrences occurrences_index j w current_word current_words dictionary_pos


%%%%%the final step, merge similar words 

[dictionary_unique,~,dictionary_unique_index]=unique(dictionary_final);

occurrences_unique=zeros(numel(dictionary_unique),1);

tic
for i=1:numel(dictionary_unique)
if(mod(i,1000)==0); toc; disp(sprintf('Word %d',i)); tic; end
dic_mask=(dictionary_unique_index==i);
occurrences_unique(i)=sum(occurrences_final(dic_mask));
dictionary_unique_index(dic_mask)=[];
occurrences_final(dic_mask)=[];
end
toc

clearvars -except keepVariables occurrences_unique dictionary_unique

[occurrences_final,occurrences_index]=sort(occurrences_unique,'descend');
dictionary_final=dictionary_unique(occurrences_index);

clear dictionary_unique occurrences_unique occurrences_index

save('google_fiction2020_v20220219.mat');

