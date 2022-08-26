clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected');

diachronic_words=SNLP_loadWords([SANETOOLBOX,'/diachronic_eng.txt']);

mask_words=zeros(numel(dictionary_corrected),1);
for i=1:numel(dictionary_corrected)
pos=find(strcmp(dictionary_corrected(i),diachronic_words));
if(~isempty(pos)); mask_words(i)=1; end
end

dictionary_corrected(mask_words>0)
disp(sprintf('Percentage of diachronic words among significant words: %.2f%%',sum(mask_words)/numel(dictionary_corrected)*100));
