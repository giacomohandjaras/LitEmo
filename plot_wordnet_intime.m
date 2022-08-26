clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected','covariates','data_final_corrected');
WORDNET=load('wordnet/wordnet_clustering_v20220124.mat');

save_derivatives=1;
draw_titles=0;
label_fontsize=22+6;
tick_fontsize=18+6;
legend_fontsize=24+6;

colorclasses=[141,211,199
255,255,179
190,186,218
251,128,114
128,177,211
253,180,98
179,222,105
252,205,229
217,217,217
188,128,189
204,235,197]./255;
colorclasses=flipud(colorclasses);

perctile_window=10;
smoothing_filter=0.8;
steps=perctile_window*0.20;
bootstraps=1000;


for CLASS=1:11

fig=figure(); hold on;
line([0,50],[0,0],'Color','k','LineStyle','--','LineWidth',1.5);


WORDNET.classes_labels{CLASS}
dictionary=dictionary_corrected;
selected_words=WORDNET.dictionary_corrected(WORDNET.gclasses==CLASS)
authors_year=covariates.final_authors_pubyear;
authors_gender=covariates.final_authors_gender;
data_fixed_raw_ranks_norm=data_final_corrected;

words=nan(numel(selected_words),1);
for w=1:numel(selected_words)
words(w)=find(strcmp(dictionary,selected_words(w)));
%disp(sprintf('Word: %s',selected_word));
end

temporal_windows=[];
rank_range=[0:steps:100-perctile_window];
for i=1:numel(rank_range)
temporal_windows(1,i)=prctile(authors_year,rank_range(i));
temporal_windows(2,i)=prctile(authors_year,rank_range(i)+perctile_window);
end

temporal_windows(1,1)=min(authors_year)-eps;
temporal_windows(2,end)=max(authors_year)+eps;


data_selected=data_fixed_raw_ranks_norm;
data_selected=data_selected(:,words);


data_selected_male=data_selected(authors_gender==0,:);
data_selected_female=data_selected(authors_gender==1,:);

data_time_male=authors_year(authors_gender==0);
data_time_female=authors_year(authors_gender==1);

results_time_cohend=nan(size(temporal_windows,2),1);
results_time_cohend_up=nan(size(temporal_windows,2),1);
results_time_cohend_down=nan(size(temporal_windows,2),1);


for i=1:size(temporal_windows,2)

temporal_mask=data_time_male>=temporal_windows(1,i) & data_time_male<=temporal_windows(2,i);
temp_male=data_selected_male(temporal_mask,:);

temporal_mask=data_time_female>=temporal_windows(1,i) & data_time_female<=temporal_windows(2,i);
temp_female=data_selected_female(temporal_mask,:);

temp_d=nan(size(temp_male,2),1);
for w=1:numel(temp_d)
temp_d(w) = computeCohen_d(temp_male(:,w), temp_female(:,w), 'independent'); 
end

temp_d(isnan(temp_d))=[];
temp_d(isinf(temp_d))=[];

results_time_cohend(i)=nanmean(temp_d);
bootstraps_mean=bootstrp(bootstraps,@mean,temp_d);
results_time_cohend_up(i)=prctile(bootstraps_mean,97.5);
results_time_cohend_down(i)=prctile(bootstraps_mean,2.5);

end


cohend_raw=results_time_cohend;

if (smoothing_filter>0)
temp_results_time_cohend_up=fit([1:numel(results_time_cohend_up)]',results_time_cohend_up,'smoothingspline','SmoothingParam',smoothing_filter);
time_cohend_up=temp_results_time_cohend_up([1:numel(results_time_cohend_up)]');
temp_results_time_cohend_down=fit([1:numel(results_time_cohend_down)]',results_time_cohend_down,'smoothingspline','SmoothingParam',smoothing_filter);
time_cohend_down=temp_results_time_cohend_down([1:numel(results_time_cohend_down)]');
temp_time_cohend=fit([1:numel(results_time_cohend)]',results_time_cohend,'smoothingspline','SmoothingParam',smoothing_filter);
time_cohend=temp_time_cohend([1:numel(results_time_cohend)]');
else
time_cohend=results_time_cohend;
time_cohend_up=results_time_cohend_up;
time_cohend_down=results_time_cohend_down;
end





temporal_windows=mean(temporal_windows,1);
labels_x=round(temporal_windows);

temporal_windows_cohend=1:numel(temporal_windows);
temporal_windows_cohend_mask=isnan(time_cohend_up);
temporal_windows_cohend(temporal_windows_cohend_mask)=[];
time_cohend_down(temporal_windows_cohend_mask)=[];
time_cohend_up(temporal_windows_cohend_mask)=[];
time_cohend(temporal_windows_cohend_mask)=[];
cohend_raw(temporal_windows_cohend_mask)=[];


temporal_windows_fill = [temporal_windows_cohend, fliplr(temporal_windows_cohend)];
inBetween = [time_cohend_down; flipud(time_cohend_up)];
fill(temporal_windows_fill, inBetween,colorclasses(CLASS,:),'FaceAlpha',0.66,'LineStyle','none');
plot(temporal_windows_cohend,time_cohend,'Color',colorclasses(CLASS,:),'LineWidth',1.5,'LineStyle','-');
scatter(1:numel(temporal_windows),cohend_raw,80,'filled','MarkerFaceColor',colorclasses(CLASS,:),'MarkerFaceAlpha',0.9,'MarkerEdgecolor','none');
if(draw_titles==1); title(WORDNET.classes_labels{CLASS}); end

ylabel('Cohen''s d','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
xlabel('historical period','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');

xticks(1:5:numel(temporal_windows));
xticklabels(labels_x(1:5:numel(temporal_windows)));
xtickangle(45);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
yticks([-1:0.2:1]);
yticklabels([-1:0.2:1]);
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)

xlim([0,numel(temporal_windows)+1])
ylim([-0.65,0.65])

set(gcf,'color',[1 1 1])
box off
pbaspect([1.25,1,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_wordnet_intime_',WORDNET.classes_labels{CLASS},'.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end

pause(2);

end
