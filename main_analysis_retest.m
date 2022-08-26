%%%%This script open ALL_TERMS/all_terms.mat which contains word occurrences, frequencies, ranks, and perform a GLM (partial-f stats) and a permutation test to address the role of SEX and SEX by HISTORICAL PERIOD.
%%%%As compared to the main_analysis.m script, this one uses ranks instead of frequencies and it is restricted on significan terms only (the one obtained from main_analysis)
clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')

rng(16576);

DATA=load('ALL_TERMS/all_terms_v20220112.mat');
covariates=load('authors_info_v20220112.mat');
permutations=10000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Variables in results_singlebook_general; #1 BOOK (or AUTHOR) ID, #2 TOTAL WORDS in the dictionary, #3 TOTAL WORDS, #4 TOTAL UNIQUE WORDS, #5 % of coverage of the dictionary #6 % coverage of the dictionary considering unique ords #7 min rank of the dictionary #8 max rank of the dictionary 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

authors=numel(covariates.final_authors);
data_fixed=nan(size(DATA.results_singlebook_general));
data_fixed_raw=nan(size(DATA.results_singlebook_raw));
data_fixed_raw_ranks=nan(size(DATA.results_singlebook_raw_ranks));
dictionary=DATA.dictionary;

%%%%%%%%%%%%%%%%%%%%
%%%% Reorder authors as defined in the covariates
%%%%%%%%%%%%%%%%%%%%

for a=1:authors
author_pos=find(DATA.results_singlebook_general(:,1)==covariates.final_authors(a));
data_fixed(a,:)=DATA.results_singlebook_general(author_pos,:);
data_fixed_raw(a,:)=DATA.results_singlebook_raw(author_pos,:);
data_fixed_raw_ranks(a,:)=DATA.results_singlebook_raw_ranks(author_pos,:);
end

clear a author_pos;


%%%%%%%%%%%%%%%%%%%%
%%%% Normalize ranks
%%%%%%%%%%%%%%%%%%%%

%%%%FOR RANKS
%%%%Each word becomes a number between 0 (at the bottom of the rank sorted list) to 1 (at the top of the list).
%%%%NANs were not processed.
data_fixed_raw_ranks_norm=nan(size(data_fixed_raw_ranks));

%%%%As in frequency, were NaN became 0 freq, here we defined the lowest rank of nan
for a=1:authors
nan_mask=isnan(data_fixed_raw_ranks(a,:));
rank_to_add=unique(tiedrank(ones(sum(nan_mask),1))); %%% the rank of nan
data_fixed_raw_ranks(a,nan_mask)=rank_to_add+data_fixed(a,11);
end

%%%
data_fixed_raw_ranks_max=max(data_fixed_raw_ranks,[],2);
for a=1:authors
for term=1:size(data_fixed_raw_ranks_norm,2)
norm_data = (log10(data_fixed_raw_ranks(a,term)) - log10(data_fixed(a,10))) / ( log10(data_fixed_raw_ranks_max(a)) - log10(data_fixed(a,10)) );
data_fixed_raw_ranks_norm(a,term)=1-norm_data; %%%% Reverse sorting (Higher frequent words have higher ranks)
end
end


%%%%%Now select the data wich will be used for the analysis
data_final=data_fixed_raw_ranks_norm;

clear a term data_fixed_raw_ranks_norm data_fixed_raw_norm data_fixed_raw_ranks data_fixed_raw ;


%%%%%%%%%%%%%%%%%%%%
%%%% Do the retest only on the terms coming from main_analysis.m
%%%%%%%%%%%%%%%%%%%%


load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected');


results_p=nan(numel(dictionary_corrected),1);
results_p_coeffs=nan(numel(dictionary_corrected),10);
results_t_coeffs=nan(numel(dictionary_corrected),10);
results_beta_coeffs=nan(numel(dictionary_corrected),10);

results_f=nan(numel(dictionary_corrected),1);
results_effect=nan(numel(dictionary_corrected),1);
results_dof=nan(numel(dictionary_corrected),2);

results_f_perm=nan(permutations,numel(dictionary_corrected));
results_t_perm=nan(permutations,numel(dictionary_corrected),10);
results_p_perm=nan(numel(dictionary_corrected),1);

tic
for term=1:numel(dictionary_corrected)
disp(sprintf('Word %d: %s...',term,dictionary_corrected(term)));	

mask=find(strcmp(dictionary_corrected{term},dictionary));
male_data=data_final(covariates.final_authors_gender==0,mask);
female_data=data_final(covariates.final_authors_gender==1,mask);


male_pubyear=covariates.final_authors_pubyear(covariates.final_authors_gender==0);
female_pubyear=covariates.final_authors_pubyear(covariates.final_authors_gender==1);

male_translated=covariates.final_authors_translated(covariates.final_authors_gender==0);
female_translated=covariates.final_authors_translated(covariates.final_authors_gender==1);

male_continent=covariates.final_authors_continent(covariates.final_authors_gender==0);
female_continent=covariates.final_authors_continent(covariates.final_authors_gender==1);

male_pubyear(isnan(male_data))=[];
female_pubyear(isnan(female_data))=[];

male_translated(isnan(male_data))=[];
female_translated(isnan(female_data))=[];

male_continent(isnan(male_data))=[];
female_continent(isnan(female_data))=[];

male_data(isnan(male_data))=[];
female_data(isnan(female_data))=[];

y=(cat(1,male_data,female_data));

all_gender=cat(1,zeros(numel(male_data),1),ones(numel(female_data),1));
all_translated=cat(1,male_translated,female_translated);
all_pubyear=tiedrank(cat(1,male_pubyear,female_pubyear));
all_continent=cat(1,male_continent,female_continent);

X=cat(2,all_gender,all_translated,all_pubyear,all_continent);

clear all_gender all_translated all_pubyear all_continent male_pubyear female_pubyear male_translated female_translated male_continent female_continent 


%%%%%One hot encoding for continents using x2fx
new_X_raw=x2fx(X,'linear',4);
%%%%%Add interaction sex*year (intercept is added by x2fx)
new_X=cat(2,new_X_raw,X(:,1).*X(:,3));
new_X_reduced=new_X;
new_X_reduced(:,[2,10])=[];

[FSTAT,pvalue,beta_full,beta_p,beta_t]=calculate_partial_f(new_X,new_X_reduced,y,0);

results_beta_coeffs(term,:)=beta_full;
results_p_coeffs(term,:) = beta_p;
results_t_coeffs(term,:) = beta_t;
results_dof(term,:)=[numel(male_data),numel(female_data)];
results_f(term)=FSTAT;
results_p(term,:)=pvalue;
results_effect(term)=mean(male_data)-mean(female_data);

for perm=1:permutations
new_X_null=new_X_raw;
temp_gender=new_X_raw(:,2);
new_X_null(:,2)=temp_gender(randperm(numel(temp_gender)));
new_X_null=cat(2,new_X_null,new_X_null(:,2).*new_X_null(:,4));
[FSTAT_null,pvalue_null,beta_full_null,beta_p_null,beta_t_null]=calculate_partial_f(new_X_null,new_X_reduced,y,0);
results_f_perm(perm,term)=FSTAT_null;
results_t_perm(perm,term,:)=beta_t_null;
end
[pvalue_perm,critical_value_at_p]=pareto_right_tail(results_f_perm(:,term),results_f(term),0.05);
results_p_perm(term)=pvalue_perm;

end
toc

clear y male_data female_data new_X new_X_reduced term pvalue_perm critical_value_at_p new_X_null temp_gender perm new_X_raw FSTAT_null pvalue_null beta_full_null beta_p_null beta_t_null FSTAT pvalue beta_full beta_p beta_t X

save('ALL_TERMS/all_terms_010_10000perm_retest_v20220203.mat');

%%%%%%%%%%%%%%%%%%%%
%%%% You can skip previous steps and start from here!!!
%%%%%%%%%%%%%%%%%%%%
%load('ALL_TERMS/all_terms_010_10000perm_retest_v20220203.mat');


%%%%%%%%%%%%%%Let's do a comparison with previous results!
OLD_RESULTS=load('ALL_TERMS/all_terms_010_10000perm_v20220112.mat','results_p_perm','dictionary','results_p','results_f_perm');

results_p_perm_old=nan(numel(dictionary_corrected),1);
results_p_old=nan(numel(dictionary_corrected),1);
results_f_perm_old=nan(permutations,numel(dictionary_corrected));
for term=1:numel(dictionary_corrected)
mask=find(strcmp(dictionary_corrected{term},OLD_RESULTS.dictionary));
results_p_perm_old(term)=OLD_RESULTS.results_p_perm(mask);
results_f_perm_old(:,term)=OLD_RESULTS.results_f_perm(:,mask);
results_p_old(term)=OLD_RESULTS.results_p(mask);
end


terms_mask=find(results_p_perm>(0.05/numel(results_p_perm)));
numel(terms_mask)
dictionary_corrected(terms_mask)


