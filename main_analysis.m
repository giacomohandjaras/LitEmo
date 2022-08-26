%%%%This script open ALL_TERMS/all_terms.mat which contains word occurrences, frequencies, ranks, and perform a GLM (partial-f stats) and a permutation test to address the role of SEX and SEX by HISTORICAL PERIOD.
%%%%Moreover, for each term, Cohen's d is measured, as well as a 2D mapping of significant words using tSNE on word2vec embeddings. 

clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')

rng(16576);

DATA=load('ALL_TERMS/all_terms_v20220112.mat');
covariates=load('authors_info_v20220112.mat');
AUTHOR_FILTER=0.10; %%%%we perform a test only on words which occur in male or female writers at least AUTHOR_FILTER*n_dof times (i.e., 10%) 
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
%%%% Normalize frequencies
%%%%%%%%%%%%%%%%%%%%

%%%%FOR FREQUENCIES
%%%%%Transform occurrencies in frequencies 
data_fixed_raw_norm=(data_fixed_raw./data_fixed(:,3))*100; 

%%%%%Now select the data wich will be used for the analysis
data_final=data_fixed_raw_norm;

clear a term data_fixed_raw_ranks_norm data_fixed_raw_norm data_fixed_raw_ranks data_fixed_raw ;


%%%%%%%%%%%%%%%%%%%%
%%%% Remove "rare" words to isolate a set of ~25k words
%%%%%%%%%%%%%%%%%%%%

data_final_sel=nan(size(data_final,1),1);
dictionary_sel=strings(1,1);

perform_test_female=sum(covariates.final_authors_gender==1)*AUTHOR_FILTER;
perform_test_male=sum(covariates.final_authors_gender==0)*AUTHOR_FILTER;

index=1;
for term=1:size(data_final,2)
male_data=data_final(covariates.final_authors_gender==0,term);
female_data=data_final(covariates.final_authors_gender==1,term);
male_data(isnan(male_data))=[];
female_data(isnan(female_data))=[];

if(sum(male_data>0)>perform_test_male | sum(female_data>0)>perform_test_female) &  (sum(male_data>0)>0) & (sum(female_data>0)>0)  %%%%se non ci sono almeno n dof non procedo!!
data_final_sel(:,index)=data_final(:,term);
dictionary_sel(index,1)=dictionary(term);
index=index+1;
end

end


dictionary=dictionary_sel;
data_final=data_final_sel;

clear female_data male_data term norm_data index dictionary_sel data_final_sel



%%%%%%%%%%%%%%%%%%%%
%%%% LET'S DO THE GLM. SINCE IT CAN TAKE A LOT OF TIME, YOU CAN SKIP THIS AND OPEN THE RESULTS (around line 390)
%%%%%%%%%%%%%%%%%%%%

results_p=nan(size(data_final,2),1);
results_p_coeffs=nan(size(data_final,2),10);
results_t_coeffs=nan(size(data_final,2),10);
results_beta_coeffs=nan(size(data_final,2),10);

results_f=nan(size(data_final,2),1);
results_effect=nan(size(data_final,2),1);
results_dof=nan(size(data_final,2),2);

results_f_perm=nan(permutations,size(data_final,2));
results_t_perm=nan(permutations,size(data_final,2),10);
results_p_perm=nan(size(data_final,2),1);

tic
for term=1:size(data_final,2)

if (mod(term,100)==0)
	toc
	disp(sprintf('Word: %s (%d out of %d)...',dictionary(term),term,size(data_final,2)));	
	tic
end

%%%%%Select data from each word and remove NANs
male_data=data_final(covariates.final_authors_gender==0,term);
female_data=data_final(covariates.final_authors_gender==1,term);

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

y=tiedrank(cat(1,male_data,female_data)); %%%rank conversion

all_gender=cat(1,zeros(numel(male_data),1),ones(numel(female_data),1));
all_translated=cat(1,male_translated,female_translated);
all_pubyear=tiedrank(cat(1,male_pubyear,female_pubyear)); %%%rank conversion
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

%[tbl,chi2,p]=crosstab(authors_gender,data_final(:,term)>0);
%[p,h]=ranksum(male_data,female_data);
%LM=fitlm(X,y,'freq ~ gender * pub_year + translated + continent','VarNames' ,{'gender','translated','pub_year','continent','freq'},'Categorical',4);

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


%%%%%%%%%%%%%%%%%%%%
%%%% Correction for multiple comparisons
%%%%%%%%%%%%%%%%%%%%
results_p_perm_multiple_comparisons=nan(size(results_p_perm));
multiple_comparisons_maxima=max(results_f_perm,[],2);
h=zeros(size(results_p_perm));

tic
for term=1:size(data_final,2)
if (mod(term,100)==0)
	toc
	disp(sprintf('Word: %s (%d out of %d)...',dictionary(term),term,size(data_final,2)));	
	tic
end
[pvalue_perm,critical_value_at_p]=pareto_right_tail(multiple_comparisons_maxima,results_f(term),0.05);
results_p_perm_multiple_comparisons(term)=pvalue_perm;
end
toc

h=results_p_perm_multiple_comparisons<0.05;

disp(sprintf('Significant words at p<0.05 %d',sum(h)));	

%sum(results_f>prctile(multiple_comparisons_maxima,95))
%h=(results_f>prctile(multiple_comparisons_maxima,95));



%%%%%%%%%%%%%%%%%%%%
%%%%Select beta coeffs of interest
%%%%%%%%%%%%%%%%%%%%
results_effect_corrected=results_effect(h,1);
dictionary_corrected=dictionary(h);
data_final_corrected=data_final(:,h);

results_beta_coeffs_corrected=results_beta_coeffs(h,[2,10]);
results_t_coeffs_corrected=results_t_coeffs(h,[2,10]);
results_t_perm_corrected=results_t_perm(:,h,[2,10]);
results_p_perm_corrected=results_p_perm(h);
results_p_coeffs_corrected=results_p_coeffs(h,[2,10]);
results_p_perm_coeffs_corrected=nan(numel(dictionary_corrected),2);


%%%%%%%%%%%%%%%%%%%%
%%%% Calculate non-parametric pvalues for each coeff
%%%%%%%%%%%%%%%%%%%%
for term=1:numel(dictionary_corrected)
for coeff=1:2
temp_null=squeeze(results_t_perm_corrected(:,term,coeff));
probe_value=results_t_coeffs_corrected(term,coeff);
if(probe_value<0)
[pvalue_coeff,critical_value_at_p]=pareto_right_tail(temp_null*-1,probe_value*-1,0.05);
else
[pvalue_coeff,critical_value_at_p]=pareto_right_tail(temp_null,probe_value,0.05);
end
results_p_perm_coeffs_corrected(term,coeff)=pvalue_coeff*2;  %%%%doubling the p-val, since is a two sided test (considering the tail symmetric)
end
end

clear term coeff pvalue_coeff critical_value_at_p probe_value temp_null


%%%%%%%%%%%%%%%%%%%%
%%%% Cohen's d: first on raw data
%%%%%%%%%%%%%%%%%%%%
results_cohen_d_raw=nan(numel(dictionary),1);

for term=1:numel(dictionary)
selected_word=dictionary(term);
word=find(strcmp(dictionary,selected_word));
%disp(sprintf('Word: %s',selected_word));

data_selected=data_final(:,term);
data_selected_male=data_selected(covariates.final_authors_gender==0);
data_selected_female=data_selected(covariates.final_authors_gender==1);
data_selected_male(isnan(data_selected_male))=[];
data_selected_female(isnan(data_selected_female))=[];
d = computeCohen_d(data_selected_male, data_selected_female, 'independent'); 
results_cohen_d_raw(term)=d;
end
results_cohen_d_raw_corrected=results_cohen_d_raw(h);



%%%%%%%%%%%%%%%%%%%%
%%%% Cohen's d: first on cleaned data
%%%%%%%%%%%%%%%%%%%%

results_cohen_d_gender=nan(numel(dictionary),1);
data_final_cleaned_gender=nan(size(data_final));

results_cohen_d_gender_time=nan(numel(dictionary),1);
data_final_cleaned_gender_time=nan(size(data_final));

results_cohen_d_gender_space=nan(numel(dictionary),1);
data_final_cleaned_gender_space=nan(size(data_final));

data_final_cleaned_all=nan(size(data_final));

tic
for term=1:size(data_final,2)

if (mod(term,100)==0)
	toc
	disp(sprintf('Word: %s (%d out of %d)...',dictionary(term),term,size(data_final,2)));	
	tic
end

%%%%%Remove nan (the occurrences of nans should be zero at this step of analysis)
y=data_final(:,term);
X=cat(2,covariates.final_authors_gender,covariates.final_authors_translated,tiedrank(covariates.final_authors_pubyear),covariates.final_authors_continent);

new_X_raw=x2fx(X,'linear',4);
%%%%%Let's add interaction sex by historical period (intercept is added by default by x2fx)
new_X=cat(2,new_X_raw,X(:,1).*X(:,3));

%%%%%Residuals for SEX
new_X_temp=new_X;
new_X_temp(:,[2,10])=[];
beta_temp = ((new_X_temp'*new_X_temp)^-1)*new_X_temp'*(y); % Coefficients
residual_temp=(y-(new_X_temp*beta_temp))+mean(y);
residual_temp(residual_temp<0)=0;
data_final_cleaned_gender(:,term)=residual_temp;
data_selected_male=residual_temp(covariates.final_authors_gender==0);
data_selected_female=residual_temp(covariates.final_authors_gender==1);
data_selected_male(isnan(data_selected_male))=[];
data_selected_female(isnan(data_selected_female))=[];
d = computeCohen_d(data_selected_male, data_selected_female, 'independent'); 
results_cohen_d_gender(term)=d;

%%%%%Residuals for SEX & HISTORICAL PERIOD
new_X_temp=new_X;
new_X_temp(:,[2,4,10])=[];
beta_temp = ((new_X_temp'*new_X_temp)^-1)*new_X_temp'*(y); % Coefficients
residual_temp=(y-(new_X_temp*beta_temp))+mean(y);
residual_temp(residual_temp<0)=0;
data_final_cleaned_gender_time(:,term)=residual_temp;
data_selected_male=residual_temp(covariates.final_authors_gender==0);
data_selected_female=residual_temp(covariates.final_authors_gender==1);
data_selected_male(isnan(data_selected_male))=[];
data_selected_female(isnan(data_selected_female))=[];
d = computeCohen_d(data_selected_male, data_selected_female, 'independent'); 
results_cohen_d_gender_time(term)=d;

%%%%%Residuals for SEX & CONTINENT
new_X_temp=new_X;
new_X_temp(:,[2,5:9,10])=[];
beta_temp = ((new_X_temp'*new_X_temp)^-1)*new_X_temp'*(y); % Coefficients
residual_temp=(y-(new_X_temp*beta_temp))+mean(y);
residual_temp(residual_temp<0)=0;
data_final_cleaned_gender_space(:,term)=residual_temp;
data_selected_male=residual_temp(covariates.final_authors_gender==0);
data_selected_female=residual_temp(covariates.final_authors_gender==1);
data_selected_male(isnan(data_selected_male))=[];
data_selected_female(isnan(data_selected_female))=[];
d = computeCohen_d(data_selected_male, data_selected_female, 'independent'); 
results_cohen_d_gender_space(term)=d;

%%%%%Residuals for the full model
new_X_temp=new_X;
beta_temp = ((new_X_temp'*new_X_temp)^-1)*new_X_temp'*(y); % Coefficients
residual_temp=(y-(new_X_temp*beta_temp))+mean(y);
residual_temp(residual_temp<0)=0;
data_final_cleaned_all(:,term)=residual_temp;
end
toc


results_cohen_d_gender_corrected=results_cohen_d_gender(h);
data_final_cleaned_gender_corrected=data_final_cleaned_gender(:,h);

results_cohen_d_gender_time_corrected=results_cohen_d_gender_time(h);
data_final_cleaned_gender_time_corrected=data_final_cleaned_gender_time(:,h);

results_cohen_d_gender_space_corrected=results_cohen_d_gender_space(h);
data_final_cleaned_gender_space_corrected=data_final_cleaned_gender_space(:,h);

data_final_cleaned_all_corrected=data_final_cleaned_all(:,h);


save('ALL_TERMS/all_terms_010_10000perm_v20220112.mat');

clear results_f_perm results_t_perm
save('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat');


%%%%%%%%%%%%%%%%%%%%
%%%% You can skip previous steps and start from here!!!
%%%%%%%%%%%%%%%%%%%%
%load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat');


%%%%%%%%%%%%%%%%%%%%
%%%% Fix bigrams
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

dictionary_bigrams=dictionary;
for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary,bigram_to_search));
if numel(pos)>0
dictionary_bigrams(pos)=bigram_to_replace;
end
end



%%%%%%%%%%%%%%%%%%%%
%%%% Using tSNE to map word2vec embeddings in a 2D plane
%%%%%%%%%%%%%%%%%%%%


CORPORA=load('word2vec_embeddings/corpora_litemo_a05s512w5s1E03_v20220112.mat');
CORPORA.word2vec_vectors=nan(numel(dictionary_corrected),512);

for w=1:numel(dictionary_corrected)
CORPORA.temp_position=strcmp(CORPORA.wordlist,dictionary_corrected(w));
CORPORA.word2vec_vectors(w,:)=CORPORA.vectors_matrix(find(CORPORA.temp_position),:);
end

CORPORA.word2vec_rdm=pdist(CORPORA.word2vec_vectors,'cosine');

CORPORA.overall_link=linkage(CORPORA.word2vec_rdm,'average');
CORPORA.overall_order = optimalleaforder(CORPORA.overall_link,CORPORA.word2vec_rdm);
CORPORA.overall_sim_reorder=SNLP_reorderRDM(squareform(CORPORA.word2vec_rdm),CORPORA.overall_order);

figure()
imagesc(CORPORA.overall_sim_reorder)
colormap(jet)
caxis([prctile(CORPORA.word2vec_rdm,10),prctile(CORPORA.word2vec_rdm,90)])
yticks([1:1:numel(dictionary_corrected)]);
yticklabels(dictionary_corrected_bigrams(CORPORA.overall_order));
xticks([1:1:numel(dictionary_corrected)]);
xticklabels(dictionary_corrected_bigrams(CORPORA.overall_order));
xtickangle(45);
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',1)
axis square
title(['RDM of word embeddings of ',num2str(size(CORPORA.word2vec_vectors,1),'%d'), ' terms'],'fontsize',10)
set(gca,'TickLength', [0, 0])
hold off
clear a w


%%%%%%%%%%%%%%%%%%%%
%%%% Let's do tSNE and save results. To plot results, please refer to plot_tSNE.m script
%%%%%%%%%%%%%%%%%%%%

[CORPORA.COEFF, CORPORA.SCORE, CORPORA.LATENT] = pca(squareform(CORPORA.word2vec_rdm));
%%%% Let's retain 66% of the total variance (around 10 components)
position=find(cumsum(CORPORA.LATENT(1:30))./sum(CORPORA.LATENT)<0.66);
position=position(end)+1;


%addpath('tSNE/');
%cd 'tSNE/'
%tsne_coord=fast_tsne(squareform(CORPORA.word2vec_rdm), 2, position, 40, 0.1);
%cd '../'
save('ALL_TERMS/tsne_v20220112.mat','tsne_coord');
