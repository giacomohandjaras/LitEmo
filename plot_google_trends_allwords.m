clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')

save_derivatives=1;

draw_titles=0;
draw_legend=1;
label_fontsize=22-4;
tick_fontsize=18-4;
legend_fontsize=18-2;

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;
male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected','dictionary','covariates','data_final','data_final_corrected','results_t_coeffs');
GOOGLE=load('GOOGLE/google_fiction2020_v20220219_intime.mat');


%%%%%%%%%%%%%%%%%%%%
%%%% Fix bigrams
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


%%%%% first of all, let's reconstruct the google data dor the current dictionary 
GOOGLE_DATA=nan(numel(dictionary),numel(GOOGLE.timeline));

tic
for w=1:numel(dictionary)
if(mod(w,100)==0); toc; disp(sprintf('Word %d/%d',w,numel(dictionary))); tic; end
word=dictionary{w};
%disp(sprintf('Word: %s',word));
term=find(strcmp(GOOGLE.dictionary_final,word));
if (~isempty(term))
data_google=zeros(numel(GOOGLE.timeline),1);
for j=1:numel(GOOGLE.time_steps)-1
occurrences_temp_all=GOOGLE.occurrences_final{j};
mask_temp=(GOOGLE.timeline>=GOOGLE.time_steps(j) & GOOGLE.timeline<GOOGLE.time_steps(j+1)); 
data_google(find(mask_temp))=occurrences_temp_all(term,:);
clear occurrences_temp_all mask_temp
end
data_google=(data_google./GOOGLE.occurrences_intime).*100;
data_google(end)=data_google(end-1); %%% "fix" 2020 issues of Google Books
GOOGLE_DATA(w,:)=data_google;
end
end


clear j data_google term bigram_to_replace bigram_to_search express w pos word GOOGLE.occurrences_final


rng(16576);

results_beta=nan(numel(dictionary),4);
tic
for w=1:numel(dictionary)

if(mod(w,25)==0); toc; mask=mean(results_beta,2); temp_results=results_beta(~isnan(mask),:); disp(sprintf('Word %d/%d, corr AllvsG %.3f, corr MvsG %.3f, corr FvsG %.3f',w,numel(dictionary),corr(temp_results(:,1),temp_results(:,4)),corr(temp_results(:,2),temp_results(:,4)),corr(temp_results(:,3),temp_results(:,4)))); tic; end

if (~isnan(sum(GOOGLE_DATA(w,:))))

[results_time_raw,results_time,results_time_up,results_time_down,temporal_windows]=getdata_ngram_viewer(data_final(:,w),covariates.final_authors_pubyear);
[results_time_raw_female,results_time_female,results_time_up_female,results_time_down_female,temporal_windows_female]=getdata_ngram_viewer(data_final(covariates.final_authors_gender==1,w),covariates.final_authors_pubyear(covariates.final_authors_gender==1));

%%%%downsampling male authors to match the same number of the females
temp_data_male=data_final(covariates.final_authors_gender==0,w);
temp_data_male_pubyear=covariates.final_authors_pubyear(covariates.final_authors_gender==0);
random_order=randperm(sum(covariates.final_authors_gender==0));
temp_data_male=temp_data_male(random_order);
temp_data_male=temp_data_male(1:sum(covariates.final_authors_gender==1));
temp_data_male_pubyear=temp_data_male_pubyear(random_order);
temp_data_male_pubyear=temp_data_male_pubyear(1:sum(covariates.final_authors_gender==1));

[results_time_raw_male,results_time_male,results_time_up_male,results_time_down_male,temporal_windows_male]=getdata_ngram_viewer(temp_data_male,temp_data_male_pubyear);
[results_time_google_raw,results_time_google]=getdata_ngram_viewer_google(GOOGLE_DATA(w,:),GOOGLE.timeline,temporal_windows);

%%%scaling to max: it's a good way to make the beta comparable across words with different frequencies
results_time_raw=(results_time_raw)./max(results_time_raw);
results_time_raw_male=(results_time_raw_male)./max(results_time_raw_male);
results_time_raw_female=(results_time_raw_female)./max(results_time_raw_female);
results_time_google_raw=(results_time_google_raw)./max(results_time_google_raw);

B=cat(2,ones(numel(results_time_raw),1),[1:numel(results_time_raw)]')\results_time_raw;
B_male=cat(2,ones(numel(results_time_raw_male),1),[1:numel(results_time_raw_male)]')\results_time_raw_male;
B_female=cat(2,ones(numel(results_time_raw_female),1),[1:numel(results_time_raw_female)]')\results_time_raw_female;

B_google=cat(2,ones(numel(results_time_google_raw),1),[1:numel(results_time_google_raw)]')\results_time_google_raw;

results_beta(w,1)=B(2);
results_beta(w,2)=B_male(2);
results_beta(w,3)=B_female(2);
results_beta(w,4)=B_google(2);

end
end
toc


clear mask temp_data_male temp_data_male_pubyear temp_results w B B_male B_female B_google results_time_raw results_time results_time_up results_time_down temporal_windows results_time_raw_male results_time_male results_time_up_male results_time_down_male temporal_windows_male results_time_raw_female results_time_female results_time_up_female results_time_down_female temporal_windows_female results_time_google_raw results_time_google


%save('GOOGLE/google_analysis_v20220228.mat','GOOGLE_DATA','dictionary','data_final','results_beta');
load('GOOGLE/google_analysis_v20220228.mat');



%%%sorting in ascending order according to abs of t-stat for sex
[~,sorting]=sort(abs(results_t_coeffs(:,2)),'ascend');
results_beta_sorted=results_beta(sorting,:);
mask=mean(results_beta_sorted,2); 
temp_results=results_beta_sorted(~isnan(mask),:); 
dictionary_sorted=dictionary(sorting);
temp_terms=dictionary_sorted(~isnan(mask));


temp_diff_male=abs((temp_results(:,2)-temp_results(:,4)));
temp_diff_female=abs((temp_results(:,3)-temp_results(:,4)));


%%%Estimate effects on a moving average window
bootstraps=1000;
window_size=5000;
steps=window_size*0.05;
smoothing_filter=0.8;
temporal_windows=[];
temporal_range=[1:steps:numel(temp_diff_male)-window_size];
for i=1:numel(temporal_range)
temporal_windows(1,i)=temporal_range(i);
temporal_windows(2,i)=temporal_range(i)+window_size;
end

temporal_windows(1,1)=1;
temporal_windows(2,end)=max(numel(temp_diff_male));

results_time_male=nan(size(temporal_windows,2),1);
results_time_male_up=nan(size(temporal_windows,2),1);
results_time_male_down=nan(size(temporal_windows,2),1);
results_time_female=nan(size(temporal_windows,2),1);
results_time_female_up=nan(size(temporal_windows,2),1);
results_time_female_down=nan(size(temporal_windows,2),1);

for i=1:size(temporal_windows,2)
temp_male=temp_diff_male(temporal_windows(1,i):temporal_windows(2,i));
results_time_male(i)=nanmean(temp_male);
temp_female=temp_diff_female(temporal_windows(1,i):temporal_windows(2,i));
results_time_female(i)=nanmean(temp_female);
if(bootstraps>0)
bootstraps_male_mean=bootstrp(bootstraps,@nanmean,temp_male);
results_time_male_up(i)=prctile(bootstraps_male_mean,97.5);
results_time_male_down(i)=prctile(bootstraps_male_mean,2.5);
bootstraps_female_mean=bootstrp(bootstraps,@nanmean,temp_female);
results_time_female_up(i)=prctile(bootstraps_female_mean,97.5);
results_time_female_down(i)=prctile(bootstraps_female_mean,2.5);
end
end


temp_f_male_up=fit([1:numel(results_time_male_up)]',results_time_male_up,'smoothingspline','SmoothingParam',smoothing_filter);
f_male_up=temp_f_male_up([1:numel(results_time_male_up)]');
temp_f_male_down=fit([1:numel(results_time_male_down)]',results_time_male_down,'smoothingspline','SmoothingParam',smoothing_filter);
f_male_down=temp_f_male_down([1:numel(results_time_male_down)]');
temp_f_male=fit([1:numel(results_time_male)]',results_time_male,'smoothingspline','SmoothingParam',smoothing_filter);
f_male=temp_f_male([1:numel(results_time_male)]');

temp_f_female_up=fit([1:numel(results_time_female_up)]',results_time_female_up,'smoothingspline','SmoothingParam',smoothing_filter);
f_female_up=temp_f_female_up([1:numel(results_time_female_up)]');
temp_f_female_down=fit([1:numel(results_time_female_down)]',results_time_female_down,'smoothingspline','SmoothingParam',smoothing_filter);
f_female_down=temp_f_female_down([1:numel(results_time_female_down)]');
temp_f_female=fit([1:numel(results_time_female)]',results_time_female,'smoothingspline','SmoothingParam',smoothing_filter);
f_female=temp_f_female([1:numel(results_time_female)]');

f_male_raw=results_time_male;
f_female_raw=results_time_female;



labels_x=round(mean(temporal_windows,1));
labels_x_cell=strsplit(num2str(labels_x./labels_x(end)*100,'%.0f%% '));



fig=figure(); hold on;

temporal_windows_female=1:numel(labels_x);
temporal_windows_male=1:numel(labels_x);

temporal_windows_fill = [temporal_windows_male, fliplr(temporal_windows_male)];
inBetween = [f_male_down; flipud(f_male_up)];
fill(temporal_windows_fill, inBetween, male_color,'FaceAlpha',0.4,'LineStyle','none');
plot(temporal_windows_male,f_male,'Color',male_color,'LineWidth',1.5,'LineStyle','-');
a=scatter(1:numel(labels_x),f_male_raw,80,'filled','MarkerFaceColor',male_color,'MarkerFaceAlpha',male_transp,'MarkerEdgecolor','none');
%plot(1:numel(temporal_windows),f_male_up,'b--','LineWidth',1)
%plot(1:numel(temporal_windows),f_male_down,'b--','LineWidth',1)

temporal_windows_fill = [temporal_windows_female, fliplr(temporal_windows_female)];
inBetween = [f_female_down; flipud(f_female_up)];
fill(temporal_windows_fill, inBetween, female_color,'FaceAlpha',0.4,'LineStyle','none');
plot(temporal_windows_female,f_female,'Color',female_color,'LineWidth',1.5,'LineStyle','-');
b=scatter(1:numel(labels_x),f_female_raw,80,'filled','MarkerFaceColor',female_color,'MarkerFaceAlpha',male_transp,'MarkerEdgecolor','none');
%plot(temporal_windows_female,f_female_up,'r--')
%plot(temporal_windows_female,f_female_down,'r--')
box off
%pbaspect([3 1 1])
xlim([0,numel(labels_x)+1])
if(draw_titles==1); title('Similarity between our trends and the ones from Google','FontSize',legend_fontsize+4,'FontName','Arial'); end;
ylabel('trend dissimilarity with Google','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
xlabel('25k words, from the lowest to the highest sex effect','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
ax = fig.Children;
ax.YAxis.Exponent = 0;

limite_y_inf=min(cat(1,f_male_down(:),f_female_down(:)));
limite_y_sup=max(cat(1,f_male_up(:),f_female_up(:)));
if(limite_y_inf<0); limite_y_inf=0; end
ax.YLim = [limite_y_inf,limite_y_sup+eps];

yticks([]);
xticklabels([]);
xticks(1:8:numel(labels_x));
xticklabels(labels_x_cell(1:8:numel(labels_x)));
xtickangle(45);

if(draw_legend==1); 
%legend('CI95 Male','Male interp','Male raw','CI95 Female','Female interp','Female raw','Location','best'); end
[~, lgd]=legend([a,b],{'Male','Female'},'Location','best','FontSize',legend_fontsize,'FontName','Arial');
lgd_markers=findobj(lgd, 'type', 'Patch');
lgd_markers(1).MarkerSize=16;
lgd_markers(2).MarkerSize=16;
lgd_markers(1).MarkerFaceColor=male_color_transp;
lgd_markers(2).MarkerFaceColor=female_color_transp;
end

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)

set(gcf,'color',[1 1 1])
box off
pbaspect([1.25,0.85,1])
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_google_trends_allwords_sex_effect.png');
export_fig(image_filename,'-m3','-nocrop', '-transparent','-silent');
end
pause(1);




%%%scatter raw of all the trends
mask=mean(results_beta,2); 
temp_results=results_beta(~isnan(mask),:); 
temp_diff=abs((temp_results(:,1)-temp_results(:,4)));
terms_to_plot=zeros(numel(temp_diff),1);
terms_to_plot(temp_diff>prctile(temp_diff,95))=1;
temp_terms=dictionary(~isnan(mask));

[rho,p]=corr(temp_results(:,1),temp_results(:,4),'type','spearman');
scorr = @(a,b)(corr(a,b,'type','Spearman'));
bootstat = bootstrp(1000,scorr,temp_results(:,1),temp_results(:,4));
disp(sprintf('Correlation between trends in our corpus and Google Fiction 2020: %.3f, CI95: %.3f %.3f, p=%.8f ',rho,prctile(bootstat,2.5),prctile(bootstat,97.5),p));

figure(); hold on
line([0,0],[-0.03,0.03],'linewidth',0.1,'linestyle','--','color','k')
line([-0.03,0.03],[0,0],'linewidth',0.1,'linestyle','--','color','k')
line([-0.03,0.03],[-0.03,0.03],'linewidth',0.1,'linestyle','--','color','k')
scatter((temp_results(:,1)),(temp_results(:,4)),10, [0.2,0.2,0.2], 'filled','MarkerFaceAlpha',0.5,'MarkerEdgecolor','none');
hs=lsline;
hs(1).Color='k';
hs(1).LineWidth=2;
%text(temp_results(terms_to_plot>0,1)+0.00001,temp_results(terms_to_plot>0,4)+0.00001,temp_terms(terms_to_plot>0),'FontSize',9);
xlim([-0.03,0.03])
ylim([-0.03,0.03])
axis square
xlabel('Linear trends in our corpus (norm \beta)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
ylabel('Linear trends in Google (norm \beta)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
if(draw_titles==1); title('Linear trends estimated in our corpus and Google Fiction 2020'); end
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_google_trends_allwords_trends.png');
export_fig(image_filename,'-m3','-nocrop', '-transparent','-silent');
end
pause(1);


