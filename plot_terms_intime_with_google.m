clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')

save_derivatives=1;
draw_titles=1;
draw_legend=1;
label_fontsize=22-2;
tick_fontsize=18-2;
legend_fontsize=16;

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected','dictionary','covariates','data_final','data_final_corrected');
GOOGLE=load('GOOGLE/google_fiction2020_v20220219_intime.mat');

dictionary=dictionary_corrected;
data_final=data_final_corrected;

%%% Fix bigrams
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
%disp(sprintf('Word %s',word));
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



for term=1:numel(dictionary)

if (~isnan(sum(GOOGLE_DATA(term,:))))

disp(sprintf('Word %d: %s',term, dictionary(term)));
[results_time_raw,results_time,results_time_up,results_time_down,temporal_windows]=getdata_ngram_viewer(data_final(:,term),covariates.final_authors_pubyear);
[results_time_google_raw,results_time_google]=getdata_ngram_viewer_google(GOOGLE_DATA(term,:),GOOGLE.timeline,temporal_windows);


temporal_windows_plot=mean(temporal_windows);
labels_x=round(temporal_windows_plot);

temporal_windows_final=1:numel(temporal_windows_plot);
temporal_windows_final_mask=isnan(results_time_up);
temporal_windows_final(temporal_windows_final_mask)=[];
results_time_down(temporal_windows_final_mask)=[];
results_time_up(temporal_windows_final_mask)=[];
results_time(temporal_windows_final_mask)=[];
temporal_windows_fill = [temporal_windows_final, fliplr(temporal_windows_final)];
inBetween = [results_time_down; flipud(results_time_up)];

fig=figure(); hold on;
fill(temporal_windows_fill, inBetween, 'k','FaceAlpha',0.1,'LineStyle','none');
plot(temporal_windows_final,results_time,'k','LineWidth',1.5,'LineStyle','-');
a=scatter(1:numel(temporal_windows_plot),results_time_raw,80,'filled','MarkerFaceColor','k','MarkerFaceAlpha',0.66,'MarkerEdgecolor','none');
plot(1:numel(temporal_windows_plot),results_time_google,'Color',[231,41,138]./255,'LineWidth',1.5,'LineStyle','-');
b=scatter(1:numel(temporal_windows_plot),results_time_google_raw,80,'filled','MarkerFaceColor',[231,41,138]./255,'MarkerFaceAlpha',0.66,'MarkerEdgecolor','none');
box off

ylabel('frequency (%)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
xlabel('historical period','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');

xticks(1:5:numel(temporal_windows_plot));
xticklabels(labels_x(1:5:numel(temporal_windows_plot)));
xtickangle(45);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)

ax = fig.Children;
ax.YAxis.Exponent = 0;


if max(results_time(:)>0.01)
ytickformat('%.4f');
end

if max(results_time(:)>0.1)
ytickformat('%.3f');
end

if max(results_time(:)>1)
ytickformat('%.2f');
end

limit_y_inf=min(cat(1,results_time_down(:),results_time_google_raw(:)));
limit_y_sup=max(cat(1,results_time_up(:),results_time_google_raw(:)));
if(limit_y_inf<0); limit_y_inf=0; end
ax.YLim = [limit_y_inf,limit_y_sup+eps];
%ylim([4,4.4])

ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)

xlim([0,numel(temporal_windows_plot)+1])

if(draw_legend==1); 
[~, lgd]=legend([a,b],{'Our Corpus','Google'},'Location','northwest','FontSize',legend_fontsize,'FontName','Arial');
lgd_markers=findobj(lgd, 'type', 'Patch');
lgd_markers(1).MarkerSize=16;
lgd_markers(2).MarkerSize=16;
end

if(draw_titles==1); title(dictionary(term),'FontSize',legend_fontsize+4,'FontName','Arial'); end
set(gcf,'color',[1 1 1])
box off
pbaspect([1.25,0.85,1])
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/litemo_intime_with_google/',dictionary_corrected(term),'.png');
export_fig(image_filename,'-m3','-nocrop', '-transparent','-silent');
end
pause(1);
close gcf;

end
end
 


