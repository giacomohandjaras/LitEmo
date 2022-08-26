clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat');

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;

male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

alt_color=[55,126,184]./255;
alt_transp=0.80;


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

tSNE_scaling=33;
webpage_size=1000; 
dot_size=22;

tsne_coord_scaled=((tsne_coord./tSNE_scaling)+1)*(webpage_size/2);
offsets=(min(tsne_coord_scaled)-(webpage_size-(max(tsne_coord_scaled))))/2;
tsne_coord_scaled=tsne_coord_scaled-offsets;
tsne_coord_scaled=round(tsne_coord_scaled+(dot_size/2));
tsne_coord_scaled(:,2)=1000-tsne_coord_scaled(:,2); %%%flip to account for different origin of axes in the browser


scatter(tsne_coord_scaled(:,1),tsne_coord_scaled(:,2))
axis square
xlim([0,1000]);
ylim([0,1000]);


labels={'SEX' 'SEX*HISTORICAL_PERIOD'};

%%%%%%%%%%%%%%%%%%%%
%%%% SEX Effect
%%%%%%%%%%%%%%%%%%%%

coeff=1; %%sex
coeff_alt=2; %%sex by historical period

effect_to_map=abs(log10(results_p_perm_coeffs_corrected(:,coeff)));
effect_to_map_alt=abs(log10(results_p_perm_coeffs_corrected(:,coeff_alt)));

effect_threshold_min=abs(log10(0.050));
effect_threshold_max=abs(log10(0.000001));
effect_to_map(effect_to_map<effect_threshold_min)=effect_threshold_min;
effect_to_map(effect_to_map>effect_threshold_max)=effect_threshold_max;
effect_to_map(effect_to_map_alt>effect_threshold_min)=effect_threshold_min; %%% if sex by historical period is <0.05, then we will refrain to represent the sex effect, and we will discuss/plot only the interaction

effect_direction=results_beta_coeffs_corrected(:,coeff);
effect_size_res = rescale(effect_to_map,50,100);
effect_size_res = round((effect_size_res./100).*dot_size);
effect_size_res_min=round(min(effect_size_res)-(0.50*min(effect_size_res)));

%%%Let's write on screen the dots
for w=1:numel(dictionary_corrected)
disp(sprintf('<span class=\"dot\" id=\"%s\" style=\"margin-left: %dpx; margin-top: %dpx;\" onmouseover=\"showdata(''%s'',''%s'',this);\" onmouseout=\"hidedata(''%s'',''%s'',this);\"></span>',dictionary_corrected{w},tsne_coord_scaled(w,1),tsne_coord_scaled(w,2),dictionary_corrected{w},dictionary_corrected_bigrams{w},dictionary_corrected{w},dictionary_corrected_bigrams{w}));
end


%%%Let's write on screen the words
words_string="const words = [";
for w=1:numel(dictionary_corrected)
words_string=strcat(words_string,'"',dictionary_corrected{w},'",');
end
words_string=strcat(words_string,'];');
disp(sprintf('\n\n%s',words_string));


%%%Let's write on screen the size of the words
dots_string="const sizes_S = [";
for w=1:numel(dictionary_corrected)
if(effect_to_map(w)<=effect_threshold_min); effect_size_res(w)=effect_size_res_min; end
dots_string=strcat(dots_string,'"',num2str(effect_size_res(w),'%d'),'px",');
end
dots_string=strcat(dots_string,'];');
disp(sprintf('\n\n%s',dots_string));


%%%Let's write on screen the color of the words
colors_string="const colors_S = [";
for w=1:numel(dictionary_corrected)
if(effect_direction(w)<0) color=male_color_transp; else color=female_color_transp; end
if(effect_to_map(w)<=effect_threshold_min); color=[238,238,238]./255; end
colors_string=strcat(colors_string,'"rgb(',num2str(color(1)*255,'%d'),',',num2str(color(2)*255,'%d'),',',num2str(color(3)*255,'%d'),')",');
end
colors_string=strcat(colors_string,'];');
disp(sprintf('\n\n%s',colors_string));



%%%%%%%%%%%%%%%%%%%%
%%%% Effect SEX*HISTORICAL_PERIOD
%%%%%%%%%%%%%%%%%%%%

coeff=2;
effect_to_map=abs(log10(results_p_perm_coeffs_corrected(:,coeff)));

effect_threshold_min=abs(log10(0.050));
effect_threshold_max=abs(log10(0.000001));
effect_to_map(effect_to_map<effect_threshold_min)=effect_threshold_min;
effect_to_map(effect_to_map>effect_threshold_max)=effect_threshold_max;

effect_direction=results_beta_coeffs_corrected(:,coeff);
effect_size_res = rescale(effect_to_map,50,100);
effect_size_res = round((effect_size_res./100).*dot_size);
effect_size_res_min=round(min(effect_size_res)-(0.50*min(effect_size_res)));

%%%Let's write on screen the size of the words
dots_string="const sizes_I = [";
for w=1:numel(dictionary_corrected)
if(effect_to_map(w)<=effect_threshold_min); effect_size_res(w)=effect_size_res_min; end
dots_string=strcat(dots_string,'"',num2str(effect_size_res(w),'%d'),'px",');
end
dots_string=strcat(dots_string,'];');
disp(sprintf('\n\n%s',dots_string));


%%%Let's write on screen the color of the words
colors_string="const colors_I = [";
for w=1:numel(dictionary_corrected)
if(effect_to_map(w)<=effect_threshold_min); color=[238,238,238]./255; else color=alt_color; end
colors_string=strcat(colors_string,'"rgb(',num2str(color(1)*255,'%d'),',',num2str(color(2)*255,'%d'),',',num2str(color(3)*255,'%d'),')",');
end
colors_string=strcat(colors_string,'];');
disp(sprintf('\n\n%s',colors_string));


%%%%%%%%%%%%%%%%%%%%
%%%% Plot WORDNET clustering
%%%%%%%%%%%%%%%%%%%%

WORDNET=load('wordnet/wordnet_clustering_v20220124.mat');

colorclasses=[141,211,199
255,255,179
190,186,218
251,128,114
128,177,211
253,180,98
179,222,105
252,205,229
200,200,200
188,128,189
204,235,197]./255;
colorclasses=flipud(colorclasses);


%%%Let's write on screen the color of the words
colors_string="const colors_F = [";
for w=1:numel(dictionary_corrected)
if(WORDNET.gclasses(w)==0); color=[238,238,238]./255; else color=colorclasses(WORDNET.gclasses(w),:); end
colors_string=strcat(colors_string,'"rgb(',num2str(color(1)*255,'%d'),',',num2str(color(2)*255,'%d'),',',num2str(color(3)*255,'%d'),')",');
end
colors_string=strcat(colors_string,'];');
disp(sprintf('\n\n%s',colors_string));


