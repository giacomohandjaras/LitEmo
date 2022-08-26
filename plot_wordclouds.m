clear all
clc

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/');
addpath('additional_functions/export_fig')

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat', 'covariates', 'dictionary', 'data_final');

male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;
save_derivatives=0;
draw_titles=1;

%%%%%%%%%%%%%%%%%%%%
%%%% Fix the bigrams
%%%%%%%%%%%%%%%%%%%%

customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);
for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary,bigram_to_search));
if numel(pos)>0
dictionary(pos)=bigram_to_replace;
end
end


%%%%%%%%%%The size of the windows is identical to the "litemo_intime", but here we remove the overlap
perctile_window=10;
steps=perctile_window*1;

temporal_windows=[];
rank_range=[0:steps:100-perctile_window];
for i=1:numel(rank_range)
temporal_windows(1,i)=prctile(covariates.final_authors_pubyear,rank_range(i));
temporal_windows(2,i)=prctile(covariates.final_authors_pubyear,rank_range(i)+perctile_window);
end

temporal_windows(1,1)=min(covariates.final_authors_pubyear)-eps;
temporal_windows(2,end)=max(covariates.final_authors_pubyear)+eps;

data_time_male=covariates.final_authors_pubyear(covariates.final_authors_gender==0);
data_time_female=covariates.final_authors_pubyear(covariates.final_authors_gender==1);

results_time_cohen=nan(numel(dictionary),size(temporal_windows,2));
results_time_cohen_noabs=nan(numel(dictionary),size(temporal_windows,2));


for term=1:numel(dictionary)
selected_word=dictionary(term);
word=find(strcmp(dictionary,selected_word));

data_selected=data_final(:,word);

data_selected_male=data_selected(covariates.final_authors_gender==0);
data_selected_female=data_selected(covariates.final_authors_gender==1);

for i=1:size(temporal_windows,2)
temporal_mask=data_time_male>=temporal_windows(1,i) & data_time_male<=temporal_windows(2,i); 
temp_male=data_selected_male(temporal_mask);
temp_male(isnan(temp_male))=[];

temporal_mask=data_time_female>=temporal_windows(1,i) & data_time_female<=temporal_windows(2,i);
temp_female=data_selected_female(temporal_mask);
temp_female(isnan(temp_female))=[];

d = computeCohen_d(temp_male, temp_female, 'independent'); 
results_time_cohen(term,i)=abs(d);
results_time_cohen_noabs(term,i)=(d);
end

end



words_in_wordcloud=10; %%%words for each group

temporal_windows_label=mean(temporal_windows,1);
labels_x=round(temporal_windows_label);

results_time_cohen_downsampled=results_time_cohen(:,1:1:size(results_time_cohen,2));
results_time_cohen_noabs_downsampled=results_time_cohen_noabs(:,1:1:size(results_time_cohen,2));
labels_x_downsampled=labels_x(1:1:size(results_time_cohen,2));
 
%%%Explore the max and min cohen d across all time windows (to avoid to report the same words across all wordclouds)
[~, results_time_winner_male]=max(results_time_cohen_noabs_downsampled,[],2);
[~, results_time_winner_female]=min(results_time_cohen_noabs_downsampled,[],2);

 
for w=1:size(results_time_cohen_noabs_downsampled,2)
results_mask_male=(results_time_winner_male==w);
results_mask_female=(results_time_winner_female==w);

temp_data_male=results_time_cohen_noabs_downsampled(:,w);
temp_data_female=results_time_cohen_noabs_downsampled(:,w);

temp_data_male(results_mask_male==0)=0;
temp_data_male(isnan(temp_data_male))=0;

temp_data_female(results_mask_female==0)=0;
temp_data_female(isnan(temp_data_female))=0;

[temp_data_male_sort,temp_data_male_sort_indx]=sort(temp_data_male,'descend');
[temp_data_female_sort,temp_data_female_sort_indx]=sort(temp_data_female,'ascend');

%%%Let's do a ranking 
temp_data_male_rank=tiedrank(abs(temp_data_male_sort(1:words_in_wordcloud)));
temp_data_female_rank=tiedrank(abs(temp_data_female_sort(1:words_in_wordcloud)));

temp_data_final=cat(1,temp_data_female_rank,temp_data_male_rank);
temp_dictionary=cat(1,dictionary(temp_data_female_sort_indx(1:words_in_wordcloud)),dictionary(temp_data_male_sort_indx(1:words_in_wordcloud)));
colors=cat(1,repmat(female_color_transp,words_in_wordcloud,1),repmat(male_color_transp,words_in_wordcloud,1));
figure();
wc=wordcloud(temp_dictionary,temp_data_final,'MaxDisplayWords',words_in_wordcloud*2,'Color', colors,'Shape','oval','SizePower',2);
if(draw_titles==1); title(labels_x_downsampled(w)); end
if (save_derivatives==1)
file_to_save=strjoin(["derivatives/litemo_wordcloud/",num2str(labels_x_downsampled(w)),".png"],'');
export_fig(file_to_save,'-m3','-nocrop', '-transparent','-silent');
%saveas(gcf,file_to_save);
pause(2);
close gcf;
end
end
 
