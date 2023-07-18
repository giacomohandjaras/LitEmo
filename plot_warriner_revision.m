clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/ColorBrewer/');
addpath('additional_functions/export_fig')
addpath('additional_functions/raacampbell-notBoxPlot/code');

DATA=load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected','covariates','data_final_corrected','results_cohen_d_gender_corrected','results_p_perm_coeffs_corrected');
load('ALL_TERMS/tsne_v20220112.mat');

save_derivatives=1;
draw_titles=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24+2;

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;

male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

warriner=readtable('WARRINER/BRM-emot-submit.csv','Delimiter',','); %%% ratings from Warriner (2013)
effect_of_interest='arousal'; %%CHANGE HERE THE EFFECT OF INTEREST
effects_of_interest={'valence','arousal'};
columns_of_interest=[3,12,15;6,18,21];
dimension=find(strcmp(effects_of_interest,effect_of_interest));
polarities=[2,1];
polarity=polarities(dimension);

%%%%%%%%%%%%%%%%%%%%
%%%% Filter words with SEX <0.05 (column 1 of results_p_perm_coeffs_corrected) o SEX*HISTORICAL_PERIOD<0.05 (column 2 of results_p_perm_coeffs_corrected)
%%%%%%%%%%%%%%%%%%%%
effect_of_interest_revision='sex';
DATA.mask=DATA.results_p_perm_coeffs_corrected(:,1)<0.05;
DATA.dictionary_corrected(DATA.mask==0)=[];
DATA.data_final_corrected(:,DATA.mask==0)=[];
DATA.results_cohen_d_gender_corrected(DATA.mask==0)=[];
tsne_coord(DATA.mask==0,:)=[];

%%%%%%%%%%%%%%%%%%%%
%%%% Process Warriner's terms as we did (removing space in bigrams)
%%%%%%%%%%%%%%%%%%%%
warriner_dictionary=table2cell(warriner(:,2));
warriner_dictionary=SNLP_removeSpaces(warriner_dictionary);


%%%%%%%%%%%%%%%%%%%%
%%%% Fix all our bigrams
%%%%%%%%%%%%%%%%%%%%

customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);
dictionary_corrected_bigrams=DATA.dictionary_corrected;

for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(DATA.dictionary_corrected,bigram_to_search));
if numel(pos)>0
dictionary_corrected_bigrams(pos)=bigram_to_replace;
end
end


%%%%%%%%%%%%%%%%%%%%
%%%% Prepare Warriner's scores for males and females separately
%%%%%%%%%%%%%%%%%%%%
warriner_var=table2array(warriner(1:end,columns_of_interest(dimension,1)));
warriner_var_male=table2array(warriner(1:end,columns_of_interest(dimension,2)));
warriner_var_female=table2array(warriner(1:end,columns_of_interest(dimension,3)));


%%%%%%%%%%%%%%%%%%%%
%%%% Remove words with a clear semantic shift (accordingly to literature)
%%%%%%%%%%%%%%%%%%%%
words_to_exclude=SNLP_loadWords([SANETOOLBOX,'/diachronic_eng.txt']);

mask_to_exclude=zeros(numel(warriner_dictionary),1);
for w=1:numel(warriner_dictionary)
pos=find(strcmp(words_to_exclude,warriner_dictionary{w}));
if(~isempty(pos)); mask_to_exclude(w)=1; end
end

warriner_dictionary(mask_to_exclude==1)=[];
warriner_var(mask_to_exclude==1,:)=[];
warriner_var_male(mask_to_exclude==1,:)=[];
warriner_var_female(mask_to_exclude==1,:)=[];


%%%%%%%%%%%%%%%%%%%%
%%%% Retrive Warriner's scores
%%%%%%%%%%%%%%%%%%%%

mask=zeros(numel(DATA.dictionary_corrected),1);
selected_var=zeros(numel(DATA.dictionary_corrected),1);
selected_var_male=zeros(numel(DATA.dictionary_corrected),1);
selected_var_female=zeros(numel(DATA.dictionary_corrected),1);

for i=1:numel(DATA.dictionary_corrected)
found=(strcmp(DATA.dictionary_corrected(i),warriner_dictionary));
if (sum(found)>0)
mask(i)=1;
selected_var(i)=warriner_var(find(found));
selected_var_male(i)=warriner_var_male(find(found));
selected_var_female(i)=warriner_var_female(find(found));
end
end

selected_cohen=DATA.results_cohen_d_gender_corrected(mask>0);
selected_var=selected_var(mask>0);
selected_var_male=selected_var_male(mask>0);
selected_var_female=selected_var_female(mask>0);

dictionary_selected=dictionary_corrected_bigrams(mask>0);
dictionary_discarded=dictionary_corrected_bigrams(mask==0);


disp(sprintf('Coverage of the dictionary %d/%d, %.1f%%',numel(dictionary_selected),numel(DATA.dictionary_corrected),numel(dictionary_selected)/numel(DATA.dictionary_corrected)*100));	


%%%%%%%%%%%%%%%%%%%%
%%%% Test sex differences in the scoring of words
%%%%%%%%%%%%%%%%%%%%

male_data=selected_var_male(selected_cohen>0);
female_data=selected_var_female(selected_cohen<0);

male_dictionary_selected=dictionary_selected(selected_cohen>0);
female_dictionary_selected=dictionary_selected(selected_cohen<0);

[p,h]=ranksum(male_data,female_data);
effect_var=median(male_data)-median(female_data);
bootstraps=1000;
bootstraps_male=bootstrp(bootstraps,@nanmean,male_data);
bootstraps_female=bootstrp(bootstraps,@nanmean,female_data);
bootstraps_var=bootstraps_male-bootstraps_female;
disp(sprintf('Differences of %s in Warriner, Males-Females %.2f, p=%.8f (CI95: %.2f:%.2f)',effect_of_interest,effect_var,p,prctile(bootstraps_var,2.5),prctile(bootstraps_var,97.5)));	


figure(); hold on;
if(polarity==2)
line([0,3],[5,5],[0,0],'Color','k','LineStyle','--','LineWidth',1.5);
end

%%%for unknown reasons (a bug) the boxplot change in transparency sometimes...so I repeated it multiple times until it stabilized
box_male=notBoxPlot(male_data,0.1,0.8,'jitter',0.1,'interval','SEM');hold on
scatter(ones(size(male_data))*0.1+randn(size(male_data))/60,male_data,60,'filled','MarkerFaceColor',male_color,'MarkerFaceAlpha',male_transp,'MarkerEdgecolor','none');
box_male=notBoxPlot(male_data,0.1,0.8,'jitter',0.1,'interval','SEM');hold on

box_female=notBoxPlot(female_data,0.25,0.8,'jitter',0.1,'interval','SEM');hold on
scatter(ones(size(female_data))*0.25+randn(size(female_data))/60,female_data,60,'filled','MarkerFaceColor',female_color,'MarkerFaceAlpha',female_transp,'MarkerEdgecolor','none');
box_female=notBoxPlot(female_data,0.25,0.8,'jitter',0.1,'interval','SEM');hold on
box_female=notBoxPlot(female_data,0.25,0.8,'jitter',0.1,'interval','SEM');hold on

if(draw_titles==1);title(effect_of_interest); end

xticks([]);
yticks([1:1:9]);
yticklabels([1:1:9]);
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ylabel(strcat(effect_of_interest,' ratings'),'Fontsize',label_fontsize-2,'FontName','Arial','Fontweight','bold');

h = gca;
h.XAxis.Visible = 'off';

xlim([0,0.35])
ylim([1,9])
set(gcf,'color',[1 1 1])
box off
axis square
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_warriner_revision_',effect_of_interest_revision,'_',effect_of_interest,'_ratings.png');
export_fig(image_filename,'-m12','-nocrop', '-transparent','-silent');
end



%%%%%%%%%%%%%%%%%%%%
%%%% Map effects using tSNE
%%%%%%%%%%%%%%%%%%%%

if(strcmp(effect_of_interest,'valence'))
words_to_map={'love', 'happy','laugh', 'daughter', 'eyes','strike','madman','traffic', 'heart', 'family', 'baby', 'collision', 'veteran', 'sergeant', 'summer', 'sweet', 'woman', 'mother', 'clothes', 'satin',  'hate', 'wedding', 'pity', 'pillow', 'cake', 'arrest', 'chocolate', 'selfish', 'mob', 'assault', 'fuck', 'bullshit', 'bullet', 'scold', 'interrogation', 'team', 'legend', 'billion', 'original', 'view', 'surf', 'upper', 'house', 'east'};
end

if(strcmp(effect_of_interest,'arousal'))
words_to_map={'dress', 'sparkly', 'bearded', 'tobacco', 'sugar', 'christmas', 'pregnant', 'summer', 'cry', 'hate', 'happy', 'beautiful', 'child', 'spend', 'children', 'heart', 'two', 'fucking', 'porn', 'player', 'shooter', 'weapon', 'roar', 'speed', 'assault', 'runner', 'platoon', 'forces', 'leader', 'arrest', 'military', 'investigation', 'industrial', 'legendary', 'action', 'battle', 'strike', 'quarter', 'traffic', 'approach', 'evidence', 'lace', 'sew' };
end


tsne_coord_selected=tsne_coord(mask>0,:);

figure(); hold on;
colors=brewermap([],"RdYlBu");
colors=flipud(colors);
hold on

if (polarity==1)
colors(1:round(size(colors,1)/2),:)=[];
end

num_of_colors=size(colors,1);

colors_scale=linspace(3,7,num_of_colors); %%%scaling from 3 to 7
if (polarity==1)
point_scale=linspace(20,80,num_of_colors);
else
point_scale=[linspace(80,20,floor(num_of_colors/2)),linspace(20,80,ceil(num_of_colors/2))];
end

if (polarity==1)
sorting_var=selected_var;
else
sorting_var=abs(selected_var-5);
end

[~,sorting_order]=sort(sorting_var,'ascend');

for x=1:numel(dictionary_selected)
w=sorting_order(x);

if(selected_cohen(w)<0)
value_to_plot=selected_var_female(w);
else
value_to_plot=selected_var_male(w);
end
pos=abs(colors_scale-value_to_plot);
[~,pos]=min(pos);
scatter(tsne_coord_selected(w,1),tsne_coord_selected(w,2),point_scale(pos),'filled','MarkerFaceColor',colors(pos,:),'MarkerFaceAlpha',0.50,'MarkerEdgecolor','none');
end

for x=1:numel(dictionary_selected)
w=sorting_order(x);
word_to_map=dictionary_selected{w};
word_write_text=find(strcmp(words_to_map, word_to_map));
if(numel(word_write_text)>0)
text(tsne_coord_selected(w,1)+0.5,tsne_coord_selected(w,2)+randn(1)/2,word_to_map, 'FontSize',tick_fontsize-10,'FontName','Arial','Fontweight','normal','Color', [0,0,0]); 
end
end


xlim([-35,38])
ylim([-35,38])
if(draw_titles==1);title(effect_of_interest); end
axis square
axis off
box off
hold off


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_warriner_revision_',effect_of_interest_revision,'_',effect_of_interest,'.png');
export_fig(image_filename,'-m12','-nocrop', '-transparent','-silent');
end

