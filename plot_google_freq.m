clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/export_fig')

save_derivatives=1;
draw_titles=0;
draw_legend=1;
label_fontsize=22-2;
tick_fontsize=18-2;
legend_fontsize=18;

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected');
load('ALL_TERMS/all_terms_v20220112.mat','dictionary','results_singlebook_general','results_singlebook_raw');
GOOGLE=load('GOOGLE/google_fiction2020_v20220219.mat');



%%%%%%%%%%%%%%%%%%%%
%%%% calculate word frequency in google fiction2020
%%%%%%%%%%%%%%%%%%%%

google_frequency_all=(GOOGLE.occurrences_final./sum(GOOGLE.occurrences_final))*100;

%%%%%%%%%%%%%%%%%%%%
%%%% Fix bigrams
%%%%%%%%%%%%%%%%%%%%

customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);
dictionary_corrected_without_bigrams=dictionary_corrected;
for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
pos=find(strcmp(dictionary_corrected_without_bigrams,bigram_to_search));
if numel(pos)>0
dictionary_corrected_without_bigrams(pos)=[];
end
end


%%%%%%%%%%%%%%%%%%%%
%%%% Get frequency in our corpus
%%%%%%%%%%%%%%%%%%%%

litemo_frequency=zeros(numel(dictionary_corrected_without_bigrams),1);
total_number_of_words=sum(results_singlebook_general(:,3));

for w=1:numel(dictionary_corrected_without_bigrams)
pos=find(strcmp(dictionary,dictionary_corrected_without_bigrams{w}));
litemo_frequency(w,1)=(sum(results_singlebook_raw(:,pos))./total_number_of_words)*100;
end


%%%%%%%%%%%%%%%%%%%%
%%%% Get frequency of google
%%%%%%%%%%%%%%%%%%%%

google_frequency=nan(numel(dictionary_corrected_without_bigrams),1);

for w=1:numel(dictionary_corrected_without_bigrams)
pos=find(strcmp(GOOGLE.dictionary_final,dictionary_corrected_without_bigrams{w}));
if numel(pos)>0
google_frequency(w,1)=google_frequency_all(pos);
end
end



%%%%%%%%%%%%%%%%%%%%
%%%% Plot the scatter
%%%%%%%%%%%%%%%%%%%%

ratio=(litemo_frequency./google_frequency);
ratio_mean=mean(ratio);
ratio_se=std(ratio)./sqrt(numel(ratio)-1);

disp(sprintf('Ratio between our_corpus/Google_2020: %.3f, SE %.3f',ratio_mean,ratio_se));	

terms_to_plot=zeros(numel(dictionary_corrected_without_bigrams),1);
terms_to_plot(ratio>prctile(ratio,97.5))=1;
terms_to_plot(ratio<prctile(ratio,2.5))=1;


[rho,p]=corr(litemo_frequency,google_frequency,'type','spearman');
scorr = @(a,b)(corr(a,b,'type','Spearman'));
bootstat = bootstrp(1000,scorr,litemo_frequency,google_frequency);
disp(sprintf('Correlation between frequency in our corpus and Google Fiction 2020: %.3f, CI95: %.3f %.3f, p=%.8f ',rho,prctile(bootstat,2.5),prctile(bootstat,97.5),p));


figure();
plot(abs(log10((0:1:max(litemo_frequency.*1E6)))+1),abs(log10((0:1:max(litemo_frequency.*1E6)))+1),'linewidth',1,'linestyle','--','color','k'); hold on
scatter((log10(litemo_frequency*1E6)),(log10(google_frequency*1E6)),40, [0.2,0.2,0.2], 'filled','MarkerFaceAlpha',0.20,'MarkerEdgecolor','none'); hold on
xlabel('log10(occurrences per million), our corpus','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
ylabel('log10(occurrences per million), Google','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
text(log10(litemo_frequency(terms_to_plot>0)*1E6)+0.08,log10(google_frequency(terms_to_plot>0)*1E6)+0.05,dictionary_corrected_without_bigrams(terms_to_plot>0),'FontSize',tick_fontsize-10,'Color','k');
if(draw_titles==1); title('Comparison between frequencies in our corpus and in Google Fiction 2020'); end
axis square
xlim([1,7]);
ylim([1,7]);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_google_freq.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end



