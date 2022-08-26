clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat');

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;

male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

alt_color=[55,126,184]./255;
alt_transp=0.80;

save_derivatives=0;
draw_titles=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24+2;

%%%%%%%%%%%%%%%%%%%%
%%%% Fix Bigrams
%%%%%%%%%%%%%%%%%%%%

customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);
dictionary_corrected_bigrams=dictionary_corrected;

for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary_corrected,bigram_to_search));
if numel(pos)>0
dictionary_corrected_bigrams(pos)=bigram_to_replace;
end
end



load('ALL_TERMS/tsne_v20220112.mat');

labels={'SEX' 'SEX*HISTORICAL_PERIOD'};

%%%%%%%%%%%%%%%%%%%%
%%%% SEX Effect
%%%%%%%%%%%%%%%%%%%%

coeff=1; %%sex
coeff_alt=2; %%sex by historical period
words_to_map={'men', 'house','the','sir','beautiful', 'shirt', 'house', 'love', 'hair', 'family', 'lady', 'husband', 'care', 'hundred', 'kitchen', 'line', 'tears', 'general', 'dinner', 'smoke', 'direction', 'flowers', 'crying', 'marry', 'another', 'officer' 'lower', 'report', 'forms','perimeter','manned', 'action', 'metal', 'dress', 'seconds', 'system','curtains', 'quarter', 'evidence', 'speed', 'sewing', 'yards', 'beard', 'numbers', 'basket', 'hurt' 'babies', 'blade', 'administration', 'liquor', 'examination', 'selfish', 'rifles', 'revolver', 'fuel', 'tease', 'cookies', 'gunner', 'urinal'};

effect_to_map=abs(log10(results_p_perm_coeffs_corrected(:,coeff)));
effect_to_map_alt=abs(log10(results_p_perm_coeffs_corrected(:,coeff_alt)));

effect_threshold_min=abs(log10(0.050));
effect_threshold_max=abs(log10(0.000001));
effect_to_map(effect_to_map<effect_threshold_min)=effect_threshold_min;
effect_to_map(effect_to_map>effect_threshold_max)=effect_threshold_max;
effect_to_map(effect_to_map_alt>effect_threshold_min)=effect_threshold_min; %%% if sex by historical period is <0.05, then we will refrain to represent the sex effect, and we will discuss/plot only the interaction

effect_direction=results_beta_coeffs_corrected(:,coeff);
effect_size_res = rescale(effect_to_map,20,80);
scaling_dot_factor=1;

figure(); hold on;

[~,sorting_order]=sort(effect_to_map,'ascend');

for x=1:numel(dictionary_corrected)
w=sorting_order(x);
if(effect_direction(w)<0) color=male_color; transp=male_transp; else color=female_color; transp=female_transp; end
if(effect_to_map(w)<=effect_threshold_min); effect_size_res(w)=10; color=[0,0,0]; transp=0.25; end
scatter(tsne_coord(w,1),tsne_coord(w,2),round(effect_size_res(w)/scaling_dot_factor),'filled','MarkerFaceColor',color,'MarkerFaceAlpha',transp,'MarkerEdgecolor','none');
end

for x=1:numel(dictionary_corrected)
w=sorting_order(x);
word_to_map=dictionary_corrected_bigrams{w};
word_write_text=find(strcmp(words_to_map, word_to_map));
if(numel(word_write_text)>0)
text(tsne_coord(w,1)+0.50,tsne_coord(w,2)+randn(1)/2,word_to_map, 'FontSize',tick_fontsize-10,'FontName','Arial','Fontweight','normal','Color', [0,0,0]); 
end
end
xlim([-35,38])
ylim([-35,38])
if(draw_titles==1);title(labels{coeff});end
axis square
axis off
box off
hold off


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_tSNE_sex.png');
export_fig(image_filename,'-m12','-nocrop', '-transparent','-silent');
end




figure(); hold on;
[~,sorting_order]=sort(effect_to_map,'ascend');

for x=1:numel(dictionary_corrected)
w=sorting_order(x);
if(effect_direction(w)<0) color=male_color; transp=male_transp; else color=female_color; transp=female_transp; end
%if(effect_to_map(w)>effect_threshold_min)
scatter(tsne_coord(w,1),tsne_coord(w,2),round(effect_size_res(w)/scaling_dot_factor),'filled','MarkerFaceColor',color,'MarkerFaceAlpha',transp,'MarkerEdgecolor','none');
%end
end

xlim([-35,38])
ylim([-35,38])
if(draw_titles==1);title(labels{coeff});end
axis square
axis off
box off
hold off


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_tSNE_sex_clustering.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end


%%%%%%%%%%%%%%%%%%%%
%%%% Effect SEX*HISTORICAL_PERIOD
%%%%%%%%%%%%%%%%%%%%

coeff=2;
words_to_map={'mrs', 'she', 'always', 'lived','hesitatingly','mounted', 'anxiously', 'arms', 'tenderly', 'unkindness', 'happy', 'likend', 'longed', 'loving', 'hate', 'pregnant', 'taught', 'nurse', 'holidays', 'tea-table', 'shopping', 'geraniums', 'mascara', 'knitting', 'shawl', 'fuchsia', 'forearm', 'stomach', 'motherfucker', 'porn', 'killers', 'gandhi', 'shotgun', 'diesel', 'explosives', 'parked', 'world-war', 'teams', 'air-force', 'colonel', 'interrogation', 'final', 'legendary', 'parked', 'area', 'amplified', 'paces', 'led', 'question', 'fellows'};
effect_to_map=abs(log10(results_p_perm_coeffs_corrected(:,coeff)));

effect_threshold_min=abs(log10(0.050));
effect_threshold_max=abs(log10(0.000001));
effect_to_map(effect_to_map<effect_threshold_min)=effect_threshold_min;
effect_to_map(effect_to_map>effect_threshold_max)=effect_threshold_max;

effect_direction=results_beta_coeffs_corrected(:,coeff);
effect_size_res = rescale(effect_to_map,20,80);
scaling_dot_factor=1;

figure(); hold on;

[~,sorting_order]=sort(effect_to_map,'ascend');

for x=1:numel(dictionary_corrected)
w=sorting_order(x);
if(effect_to_map(w)<=effect_threshold_min); effect_size_res(w)=10; color=[0,0,0]; transp=0.25; else color=alt_color; transp=alt_transp; end
scatter(tsne_coord(w,1),tsne_coord(w,2),round(effect_size_res(w)/scaling_dot_factor),'filled','MarkerFaceColor',color,'MarkerFaceAlpha',transp,'MarkerEdgecolor','none');
end

for x=1:numel(dictionary_corrected)
w=sorting_order(x);
word_to_map=dictionary_corrected_bigrams{w};
word_write_text=find(strcmp(words_to_map, word_to_map));
if(numel(word_write_text)>0)
text(tsne_coord(w,1)+0.50,tsne_coord(w,2)+randn(1)/2,word_to_map, 'FontSize',tick_fontsize-10,'FontName','Arial','Fontweight','normal','Color', [0,0,0]); 
end
end
xlim([-35,38])
ylim([-35,38])
if(draw_titles==1);title(labels{coeff});end
axis square
axis off
box off
hold off



if (save_derivatives==1)
image_filename = strcat('derivatives/plot_tSNE_sex_by_historical_period.png');
export_fig(image_filename,'-m12','-nocrop', '-transparent','-silent');
end




