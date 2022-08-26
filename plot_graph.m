clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/BCT')

male_color=[237,104,105]./255;
female_color=[121,192,116]./255;

continent_colors = [...
141,211,199
255,255,179
190,186,218
251,128,114
128,177,211
253,180,98]./255; 

translated_colors = [...
230,230,230
255,127,0 ]./255; 

prizes_colors = [...
230,230,230
106,61,154 ]./255; 


load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat', 'dictionary', 'data_final_cleaned_all','data_final');
covariates=load('authors_info_v20220112.mat');

data_final_norm=SNLP_ppmi(data_final.*1E6);
data_final_norm=zscore(data_final_norm);
results_rdm=pdist(data_final_norm,'cosine');

results_link=linkage(results_rdm,'average');
results_order = optimalleaforder(results_link,results_rdm);

results_rdm_reorder=squareform(results_rdm);
results_rdm_reorder=results_rdm_reorder(results_order,results_order);



figure();
imagesc(results_rdm_reorder);
colormap(jet)
caxis([prctile(results_rdm,5),prctile(results_rdm,95)])
yticks([1:1:numel(covariates.final_authors_name)]);
yticklabels(covariates.final_authors_name(results_order));
xticks([1:1:numel(covariates.final_authors_name)]);
xticklabels(covariates.final_authors_name(results_order));
xtickangle(45);
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',10)
set(gca,'XTickLabel',a,'FontName','Times','fontsize',10)
ax=gca;
ax.TickLength = [0, 0];
title('RDM of Authors')
axis square




results_rdm_rank=tiedrank(results_rdm);
results_rdm_rank=1-(results_rdm_rank./max(results_rdm_rank));
[backbone, backbone_thr] = backbone_wu(squareform(results_rdm_rank),20);
graph_attributes=cat(2,covariates.final_authors_gender,covariates.final_authors_pubyear,covariates.final_authors_continent,covariates.final_authors_translated,covariates.final_authors_nobel,covariates.final_authors_prizes+covariates.final_authors_nobel>0);

SANe_Matlab2Gephi('derivatives/graph_authors_ppmi_degree20',triu(backbone_thr),'NodeLabel',covariates.final_authors_name,'NodeAttribute',graph_attributes,'AttributeLabel',{'sex','historical_period','continent','translated','nobel','all_prizes'});


%%%%try to handle color in GEPHI
%%SEX
color=cell(size(covariates.final_authors_name));
for a=1:numel(covariates.final_authors_name)
if(covariates.final_authors_gender(a)==0)
color{a}=rgb2hex(male_color);
else
color{a}=rgb2hex(female_color);
end
end
SANe_Matlab2Gephi_color('derivatives/gephi_sex_color',triu(backbone_thr),'NodeLabel',covariates.final_authors_name,'NodeAttribute',color,'AttributeLabel',{'color'});


%%CONTINENTS
color=cell(size(covariates.final_authors_name));
for a=1:numel(covariates.final_authors_name)
color{a}=rgb2hex(continent_colors(covariates.final_authors_continent(a),:));
end
SANe_Matlab2Gephi_color('derivatives/gephi_continents_color',triu(backbone_thr),'NodeLabel',covariates.final_authors_name,'NodeAttribute',color,'AttributeLabel',{'color'});


%%TRANSLATED
color=cell(size(covariates.final_authors_name));
for a=1:numel(covariates.final_authors_name)
color{a}=rgb2hex(translated_colors(covariates.final_authors_translated(a)+1,:));
end
SANe_Matlab2Gephi_color('derivatives/gephi_translated_color',triu(backbone_thr),'NodeLabel',covariates.final_authors_name,'NodeAttribute',color,'AttributeLabel',{'color'});


%%PRIZES
color=cell(size(covariates.final_authors_name));
prizes=(covariates.final_authors_prizes+covariates.final_authors_nobel>0);
for a=1:numel(covariates.final_authors_name)
color{a}=rgb2hex(prizes_colors(prizes(a)+1,:));
end
SANe_Matlab2Gephi_color('derivatives/gephi_prizes_color',triu(backbone_thr),'NodeLabel',covariates.final_authors_name,'NodeAttribute',color,'AttributeLabel',{'color'});



