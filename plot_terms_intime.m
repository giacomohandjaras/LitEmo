clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')

save_derivatives=1;

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected','covariates','data_final_corrected');


%%%%%%%%%%%%%%%%%%%%
%%%% Fix the bigrams
%%%%%%%%%%%%%%%%%%%%

customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);
dictionary_corrected_bigrams=dictionary_corrected;

for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary_corrected,bigram_to_search));
if numel(pos)>0
dictionary_corrected_bigrams(pos)=bigram_to_replace;
end
end




for term=1:numel(dictionary_corrected)
disp(sprintf('Word %d: %s',term, dictionary_corrected_bigrams(term)));
plot_ngram_viewer_gender(dictionary_corrected_bigrams(term),'frequency (%)',covariates.final_authors_pubyear,data_final_corrected(:,term),covariates.final_authors_gender)
if (save_derivatives==1)
image_filename = strcat('derivatives/litemo_intime/',dictionary_corrected(term),'.png');
export_fig(image_filename,'-m3','-nocrop', '-transparent','-silent');
end
pause(1);
close gcf;
end

 
