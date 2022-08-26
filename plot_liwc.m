clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/');
addpath('additional_functions/export_fig')

save_derivatives=1;
draw_titles=0;
draw_legend=1;
label_fontsize=22-2;
tick_fontsize=18-2;
legend_fontsize=18;

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;
male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

positive_color=[0.6471    0.0000    0.1490];
negative_color=[0.1922    0.2118    0.5843];
transp=0.66;

covariates=load('authors_info_v20220112.mat');
POS=load('LIWC/LIWC_eng_pos_nodiachronic_v20220124.mat');
NEG=load('LIWC/LIWC_eng_neg_nodiachronic_v20220124.mat');

POS_freq=sum(POS.results_singlebook_raw,2)./POS.results_singlebook_general(:,3);
NEG_freq=sum(NEG.results_singlebook_raw,2)./NEG.results_singlebook_general(:,3);

author_order=nan(numel(covariates.final_authors),1);
for i=1:numel(covariates.final_authors)
author_order(i)=find(POS.results_singlebook_general(:,1)==covariates.final_authors(i));
end

POS_freq=POS_freq(author_order);
NEG_freq=NEG_freq(author_order);


%%%%%%%Evaluate the frequency of positive e negative words in Google Fiction 2020
dictionary=SNLP_loadWords('LIWC/LIWC2015_English_neg_nodiachronic.txt');
dic=dictionary(1:end,1);
tic
[counts, words,total_words, unique_words, unique_ranks,max_ranks,min_ranks,ranks]=SNLP_getOccurrence('GOOGLE/google_fiction2020_v20220219.dic',dic);
toc
NEG_freq_google=counts/total_words;


dictionary=SNLP_loadWords('LIWC/LIWC2015_English_pos_nodiachronic.txt');
dic=dictionary(1:end,1);
tic
[counts, words,total_words, unique_words, unique_ranks,max_ranks,min_ranks,ranks]=SNLP_getOccurrence('GOOGLE/google_fiction2020_v20220219.dic',dic);
toc
POS_freq_google=counts/total_words;

clear dictionary dic counts words total_words unique_ranks max_ranks min_ranks ranks


%%%%%%%Plot the Pollyanna effect
[p,h]=signrank(POS_freq,NEG_freq);%,'method','exact');

bootstraps_pos=bootstrp(1000,@mean,POS_freq);
bootstraps_neg=bootstrp(1000,@mean,NEG_freq);

disp(sprintf('Pos effect-size: %.3f%%, SE: %.3f%%  (Google: %.3f%%)',mean(POS_freq)*100,std(bootstraps_pos)*100,sum(POS_freq_google)*100));
disp(sprintf('Neg effect-size: %.3f%%, SE: %.3f%% (Google: %.3f%%)',mean(NEG_freq*100),std(bootstraps_neg)*100,sum(NEG_freq_google)*100));
disp(sprintf('Difference between Pos vs Neg effect-size: %.3f%%, pvalue: %.6f',(mean(POS_freq)-mean(NEG_freq))*100,p));

figure;hold on;
violinplot_holdon(POS_freq*100,1,'' ,'bandwidth',0.4,'ViolinColor',positive_color,'ViolinAlpha',transp); 
violinplot_holdon(NEG_freq*100,2,'' ,'bandwidth',0.4,'ViolinColor',negative_color,'ViolinAlpha',transp); 

line([0.6 1.4],[sum(POS_freq_google)*100,sum(POS_freq_google)*100],'LineStyle','--','Color',[66 66 66]./255,'LineWidth',2);
line([1.6 2.4],[sum(NEG_freq_google)*100,sum(NEG_freq_google)*100],'LineStyle','--','Color',[66 66 66]./255,'LineWidth',2);

if(draw_titles==1); title(['Pollyanna Effect, P-N=',num2str((mean(POS_freq)-mean(NEG_freq))*100,'%.2f'),'% p=',num2str(p,'%.4f')]); end

ylabel('word frequency %','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
xticks([]);
xlim([0.5,2.5]);

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
h = gca;
h.XAxis.Visible = 'off';

axis square
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_liwc_emo.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end





%%%%%%%Gender differences in Positive Emotions

POS_freq_male=POS_freq(covariates.final_authors_gender==0);
POS_freq_female=POS_freq(covariates.final_authors_gender==1);

[p,h]=ranksum(POS_freq_male,POS_freq_female);%,'method','exact');

bootstraps_pos_male=bootstrp(1000,@mean,POS_freq_male);
bootstraps_pos_female=bootstrp(1000,@mean,POS_freq_female);

disp(sprintf('Pos effect-size in male: %.3f%%, SE: %.3f%%',mean(POS_freq_male)*100,std(bootstraps_pos_male)*100));
disp(sprintf('Pos effect-size in female: %.3f%%, SE: %.3f%%',mean(POS_freq_female)*100,std(bootstraps_pos_female)*100));
disp(sprintf('Difference between Male-Female for Pos Emo effect-size: %.3f%%, pvalue: %.6f',(mean(POS_freq_male)-mean(POS_freq_female))*100,p));

figure;hold on;
violinplot_holdon(POS_freq_male*100,1,'' ,'bandwidth',0.4,'ViolinColor',male_color,'ViolinAlpha',male_transp); 
violinplot_holdon(POS_freq_female*100,2,'' ,'bandwidth',0.4,'ViolinColor',female_color,'ViolinAlpha',female_transp); 

if(draw_titles==1); title(['Positive Emotions, gender differences, M-F=',num2str((mean(POS_freq_male)-mean(POS_freq_female))*100,'%.2f'),'% p=',num2str(p,'%.4f')]); end
ylabel('word frequency %','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
xticks([]);
xlim([0.5,2.5]);

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
h = gca;
h.XAxis.Visible = 'off';

axis square
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_liwc_pos_by_sex.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end


%%%%%%%Gender differences in Negative Emotions

NEG_freq_male=NEG_freq(covariates.final_authors_gender==0);
NEG_freq_female=NEG_freq(covariates.final_authors_gender==1);

[p,h]=ranksum(NEG_freq_male,NEG_freq_female);%,'method','exact');

bootstraps_neg_male=bootstrp(1000,@mean,NEG_freq_male);
bootstraps_neg_female=bootstrp(1000,@mean,NEG_freq_female);

disp(sprintf('Neg effect-size in male: %.3f%%, SE: %.3f%%',mean(NEG_freq_male)*100,std(bootstraps_neg_male)*100));
disp(sprintf('Neg effect-size in female: %.3f%%, SE: %.3f%%',mean(NEG_freq_female)*100,std(bootstraps_neg_female)*100));
disp(sprintf('Difference between Male-Female for Neg Emo effect-size: %.3f%%, pvalue: %.6f',(mean(NEG_freq_male)-mean(NEG_freq_female))*100,p));

figure;hold on;
violinplot_holdon(NEG_freq_male*100,1,'' ,'bandwidth',0.4,'ViolinColor',male_color,'ViolinAlpha',male_transp); 
violinplot_holdon(NEG_freq_female*100,2,'' ,'bandwidth',0.4,'ViolinColor',female_color,'ViolinAlpha',female_transp); 

if(draw_titles==1); title(['Negative Emotions, gender differences, M-F=',num2str((mean(NEG_freq_male)-mean(NEG_freq_female))*100,'%.2f'),'% p=',num2str(p,'%.4f')]); end
ylabel('word frequency %','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
xticks([]);
xlim([0.5,2.5]);

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
h = gca;
h.XAxis.Visible = 'off';

axis square
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_liwc_neg_by_sex.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end
