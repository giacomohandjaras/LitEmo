clear all
clc

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/');
addpath('additional_functions/export_fig')

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat', 'covariates', 'dictionary', 'data_final');

save_derivatives=1;
draw_titles=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24+2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perctile_window=10;
smoothing_filter=0.8;
steps=perctile_window*0.20;

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

%disp(sprintf('Processing word %s',selected_word));

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



temporal_windows=mean(temporal_windows,1);
labels_x=round(temporal_windows);

results_time_cohen_avg=nanmean(results_time_cohen,1);

X=cat(2,ones(numel(results_time_cohen_avg),1),temporal_windows');
[b,bint,~,~,STATS] = regress(results_time_cohen_avg',X);
disp(sprintf('Change of Cohen''d every 50 years b: %.5f',b(2)*50));

X=cat(2,ones(numel(results_time_cohen_avg),1),[1:numel(temporal_windows)]');
[b,bint,~,~,STATS] = regress(results_time_cohen_avg',X);
disp(sprintf('Association between Time and cohen''s d, b: %.5f, R^2: %.3f, p-val=%.5f',b(2),STATS(1),STATS(3)));




[p,S] = polyfit([1:numel(temporal_windows)]',results_time_cohen_avg',1);
X_high=-2:0.1:(numel(temporal_windows)+3);
[y_ext,delta] = polyconf(p,X_high',S);


figure(); hold on;
scatter([1:numel(temporal_windows)],results_time_cohen_avg,60,'filled','MarkerFaceColor','k','MarkerFaceAlpha',.25,'MarkerEdgecolor','none');
plot(X_high, y_ext,'k--','LineWidth',1);
patch([X_high fliplr(X_high)], [(y_ext'+delta') fliplr((y_ext'-delta'))], 'k','FaceAlpha',0.05,'LineStyle','none');
box off
xlim([-2,numel(temporal_windows)+3])
if(draw_titles==1); title(['Cohen''s d in time, R^2=',num2str(STATS(1),'%.3f'),', p=',num2str(STATS(3),'%.5f')]); end
ylabel('absolute Cohen''s d','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
xlabel('historical period','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
xticks(1:5:numel(temporal_windows));
xticklabels(labels_x(1:5:numel(temporal_windows)));
xtickangle(45);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
yticks(0.12:0.02:0.22);
yticklabels(0.12:0.02:0.22);
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gcf,'color',[1 1 1])
%set(gca, 'YGrid', 'off', 'XGrid', 'on')
hold off
pbaspect([1.25,1,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_cohen_sex_historical_period.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end


