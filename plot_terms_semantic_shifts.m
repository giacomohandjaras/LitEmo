clear all
clc
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/Sankey/');
addpath('additional_functions/ColorBrewer/');
addpath('additional_functions/export_fig')

save_derivatives=0;
draw_titles=1;
label_fontsize=20;
tick_fontsize=20;
legend_fontsize=18;

MALE=load('word2vec_embeddings/corpora_litemo_male_a05s512w5s1E03_v20220112.mat');
FEMALE=load('word2vec_embeddings/corpora_litemo_female_a05s512w5s1E03_v20220112.mat');
ALL=load('word2vec_embeddings/corpora_litemo_a05s512w5s1E03_v20220112.mat');

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary','dictionary_corrected');

%%%prepare for wordembeddings
data_male=nan(numel(dictionary),512);
data_female=nan(numel(dictionary),512);
data_all=nan(numel(dictionary),512);

%%%%the position of words across male, female and overall embeddings is the same
for w=1:numel(dictionary)
mask=find(strcmp(dictionary{w},MALE.wordlist));
data_male(w,:)=MALE.vectors_matrix(mask,:);
data_female(w,:)=FEMALE.vectors_matrix(mask,:);
data_all(w,:)=ALL.vectors_matrix(mask,:);
end

clear MALE FEMALE ALL mask w


%%%%%Hyperalignment
[D, data_male_aligned,TRANSFORM] = procrustes(data_all, data_male,'Reflection','best'); %%%%altrimenti si creano delle distorsioni di distanza cosine
[D, data_female_aligned,TRANSFORM] = procrustes(data_all, data_female,'Reflection','best'); %%%%altrimenti si creano delle distorsioni di distanza cosine
data_female_aligned=data_female;
data_male_aligned=data_male;


data_female_embedding=data_female_aligned;
data_male_embedding=data_male_aligned;
data_all_embedding=data_all;

dictionary_embedding=dictionary;
dictionary_interest=dictionary_corrected;
clearvars -except data_female_embedding data_male_embedding data_all_embedding dictionary_embedding dictionary_interest



%%%%%Number of neighbors
K=25; %%%Hamilton uses 25


effect=nan(numel(dictionary_interest),1);
effect_noabs=nan(numel(dictionary_interest),1);
effect_dof=nan(numel(dictionary_interest),1);
words_position=nan(numel(dictionary_interest),1);

for term=1:numel(dictionary_interest)

if(mod(term,100)==0)
disp(sprintf('Word: %d',term));
end

word=find(strcmp(dictionary_interest(term),dictionary_embedding));
words_position(term)=word;

temp_dist_male=pdist2(data_male_embedding(word,:),data_male_embedding,'cosine');
[temp_dist_male_sort,temp_dist_male_indx]=sort(temp_dist_male,'ascend');
temp_dist_female=pdist2(data_female_embedding(word,:),data_female_embedding,'cosine');
[temp_dist_female_sort,temp_dist_female_indx]=sort(temp_dist_female,'ascend');

temp_list=cat(1,dictionary_embedding(temp_dist_male_indx(1:K)),dictionary_embedding(temp_dist_female_indx(1:K)));
temp_list=unique(temp_list,'stable')';

positions_of_interest=nan(numel(temp_list),1);
for w=1:numel(temp_list)
mask=find(strcmp(temp_list{w},dictionary_embedding));
positions_of_interest(w)=mask;
end

temp_male_data=data_male_embedding(positions_of_interest,:);
temp_female_data=data_female_embedding(positions_of_interest,:);

temp_male_dist=pdist(temp_male_data,'cosine');
temp_female_dist=pdist(temp_female_data,'cosine');

temp_male_weight=sum(squareform(temp_male_dist));
male_weight=temp_male_weight(1);

temp_female_weight=sum(squareform(temp_female_dist));
female_weight=temp_female_weight(1);

effect(term)=abs(male_weight-female_weight); 
effect_noabs(term)=(male_weight-female_weight);
effect_dof(term)=numel(temp_list)-1;
end

clear temp*


%%%%Before doing the permutation, let's remove the words of interest

dictionary_embedding_null=dictionary_embedding;
dictionary_embedding_null(words_position)=[];

data_male_embedding_null=data_male_embedding;
data_male_embedding_null(words_position,:)=[];

data_female_embedding_null=data_female_embedding;
data_female_embedding_null(words_position,:)=[];

permutations=10000;

effect_null=nan(permutations,1);
effect_null_noabs=nan(permutations,1);

effect_dof_null=nan(permutations,1);

null_terms=[1:numel(dictionary_embedding_null)];
null_terms=null_terms(randperm(numel(dictionary_embedding_null)));

for term_null=1:permutations
word=find(strcmp(dictionary_embedding_null(null_terms(term_null)),dictionary_embedding_null));

if(mod(term_null,100)==0)
disp(sprintf('Perm: %d',term_null));
end

temp_dist_male=pdist2(data_male_embedding_null(word,:),data_male_embedding_null,'cosine');
[temp_dist_male_sort,temp_dist_male_indx]=sort(temp_dist_male,'ascend');
temp_dist_female=pdist2(data_female_embedding_null(word,:),data_female_embedding_null,'cosine');
[temp_dist_female_sort,temp_dist_female_indx]=sort(temp_dist_female,'ascend');

temp_list=cat(1,dictionary_embedding_null(temp_dist_male_indx(1:K)),dictionary_embedding_null(temp_dist_female_indx(1:K)));
temp_list=unique(temp_list,'stable')';

positions_of_interest=nan(numel(temp_list),1);
for w=1:numel(temp_list)
mask=find(strcmp(temp_list{w},dictionary_embedding_null));
positions_of_interest(w)=mask;
end

temp_male_data=data_male_embedding_null(positions_of_interest,:);
temp_female_data=data_female_embedding_null(positions_of_interest,:);

temp_male_dist=pdist(temp_male_data,'cosine');
temp_female_dist=pdist(temp_female_data,'cosine');

temp_male_weight=sum(squareform(temp_male_dist));
male_weight=temp_male_weight(1);

temp_female_weight=sum(squareform(temp_female_dist));
female_weight=temp_female_weight(1);

effect_null(term_null)=abs(male_weight-female_weight);
effect_null_noabs(term_null)=(male_weight-female_weight);
effect_dof_null(term_null)=numel(temp_list)-1;
end

clear temp*


%%%%%Measure the p-val
effect_pvalue=nan(numel(dictionary_interest),1);

for term=1:numel(dictionary_interest)
[pvalue_perm,critical_value_at_p]=pareto_right_tail(effect_null,effect(term),0.05);
effect_pvalue(term)=pvalue_perm;
end

%%%%Bonferroni correction
dictionary_interest(effect_pvalue<(0.05/numel(dictionary_interest)))
mask_best_terms=find(effect_pvalue<(0.05/numel(dictionary_interest)));

%%%FDR correction
[h, crit_p, adj_p]=fdr_bh(effect_pvalue,0.05,'pdep','yes');
mask_best_terms=find(adj_p<0.05);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%%%% Fix bigrams
%%%%%%%%%%%%%%%%%%%%

customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);

dictionary_interest_bigrams=dictionary_interest;
for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary_interest,bigram_to_search));
if numel(pos)>0
dictionary_interest_bigrams(pos)=bigram_to_replace;
end
end


dictionary_embedding_bigrams=dictionary_embedding;
for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary_embedding,bigram_to_search));
if numel(pos)>0
dictionary_embedding_bigrams(pos)=bigram_to_replace;
end
end

%%%%%%%%%%%%%%%%%%%%
%%%Plot the Sankey
%%%%%%%%%%%%%%%%%%%%

effect_pvalue_log=effect_pvalue;
effect_pvalue_log(effect_pvalue_log>0.33)=0.33;
effect_pvalue_log(effect_pvalue_log<0.001)=0.001;
effect_pvalue_log=abs(log10(effect_pvalue_log));
effect_pvalue_log=normalize(effect_pvalue_log, 'range', [0.05,1]);

%%%%Select all
mask_best_terms=find(effect_pvalue>0);
%dictionary_interest_bigrams(effect_pvalue>0);

%%%%Select only the most significative
%mask_best_terms=find(effect_pvalue<0.01);
%dictionary_interest_bigrams(effect_pvalue<0.01)

for term=1:numel(mask_best_terms)
%%%%%retrieve neighbors
word=find(strcmp(dictionary_interest_bigrams(mask_best_terms(term)),dictionary_embedding_bigrams));
temp_dist_male=pdist2(data_male_embedding(word,:),data_male_embedding,'cosine');
[temp_dist_male_sort,temp_dist_male_indx]=sort(temp_dist_male,'ascend');
temp_dist_female=pdist2(data_female_embedding(word,:),data_female_embedding,'cosine');
[temp_dist_female_sort,temp_dist_female_indx]=sort(temp_dist_female,'ascend');
temp_list=cat(1,dictionary_embedding_bigrams(temp_dist_male_indx(1:K)),dictionary_embedding_bigrams(temp_dist_female_indx(1:K)));
temp_list=unique(temp_list,'stable')';

positions_of_interest=nan(numel(temp_list),1);
for w=1:numel(temp_list)
mask=find(strcmp(temp_list{w},dictionary_embedding_bigrams));
positions_of_interest(w)=mask;
end

temp_male_data=data_male_embedding(positions_of_interest,:);
temp_female_data=data_female_embedding(positions_of_interest,:);
temp_male_dist=pdist2(data_male_embedding(positions_of_interest(1),:),temp_male_data,'cosine');
temp_female_dist=pdist2(data_female_embedding(positions_of_interest(1),:),temp_female_data, 'cosine');
[temp_dist_male_sort,temp_dist_male_indx]=sort(temp_male_dist,'ascend');
[temp_dist_female_sort,temp_dist_female_indx]=sort(temp_female_dist,'ascend');
%[temp_list(temp_dist_male_indx)',temp_list(temp_dist_female_indx)']


%%%Remove the word of interest from the list
tested_word=temp_list(1);
temp_list(1)=[];
temp_dist_male_indx(1)=[];
temp_dist_male_indx=temp_dist_male_indx-1;
temp_dist_female_indx(1)=[];
temp_dist_female_indx=temp_dist_female_indx-1;
temp_dist_male_sort(1)=[];
temp_dist_female_sort(1)=[];


blocks_male=ones(1,numel(temp_list));
blocks_female=ones(1,numel(temp_list));

barcolors_male=repmat([0.0196    0.1882    0.3804],numel(temp_list),1);
barcolors_female=repmat([0.4039         0    0.1216],numel(temp_list),1);

connectors=zeros(numel(temp_list),numel(temp_list));

for w=1:numel(temp_list)
pos=find(strcmp(temp_list(temp_dist_male_indx(w)),temp_list(temp_dist_female_indx)));
if(pos>w & (pos-w)>numel(temp_list)/2) %%%shift down of at least half of the list
connectors(w,pos)=1;
end
if(pos<w & (w-pos)>numel(temp_list)/2) %%%shift upof at least half of the list
connectors(w,pos)=1;
end
end


% flow color
c = [.6 .6 .6];

% Panel width
w = 2; 

ymax=sankey_yheight(blocks_male,blocks_female);

figHandle=figure(); hold on;
colormap((brewermap([],"RdYlGn")));
y1_category_points=sane_sankey(blocks_male, blocks_female, connectors, 0, 0.1, [] ,ymax,barcolors_male,barcolors_female,w,c,effect_pvalue_log(mask_best_terms(term)));
for w=1:numel(temp_list)
text(-0.0010,y1_category_points(w)+0.4,strcat(temp_list(temp_dist_male_indx(w)),[" "]),'FontSize',tick_fontsize-10,'FontName','Arial','Fontweight','normal','Color', [0,0,0],'HorizontalAlignment', 'right'); hold on;
text(0.1+0.0010,y1_category_points(w)+0.4,strcat([" "],temp_list(temp_dist_female_indx(w))),'FontSize',tick_fontsize-10,'FontName','Arial','Fontweight','normal','Color', [0,0,0],'HorizontalAlignment', 'left'); hold on;
%[temp_list(temp_dist_male_indx(w)),temp_list(temp_dist_female_indx(w))]
end

ylim([-1,max(y1_category_points)+1]);
xlim([-0.1,0.2]);
if(draw_titles==1); title(tested_word,'FontSize',legend_fontsize,'FontName','Arial');end
if(draw_titles==1); text(0.022,-0.4,strcat('p=',num2str(effect_pvalue(mask_best_terms(term)),'%.5f')),'FontSize',tick_fontsize-10,'FontName','Arial','Fontweight','bold','Color', [0,0,0]); end

hold off;
pbaspect([1.25,1.5,1])

drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/litemo_semantic_shifts/',dictionary_interest{mask_best_terms(term)},'.png');
export_fig(image_filename,'-m3','-nocrop', '-transparent','-silent');
end
pause(1);
close gcf;



end


