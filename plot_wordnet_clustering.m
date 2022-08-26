clear all
clc

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/export_fig')

save_derivatives=0;


file_to_open='wordnet/576_hyper.csv';
load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected');

%%%%Open synsets
synsets=readtable('wordnet/576_synsets.xlsx');
BASIC_SYNSETS=synsets{:,2};
clear synsets

%%%%open hypernyms for each synset
temp_synsets = extractFileText(file_to_open,'Encoding', 'UTF-8');
Synsets = split(temp_synsets,newline);
Synsets=Synsets(1:numel(dictionary_corrected));

Synsets_cell=cell(numel(dictionary_corrected),1);
total_words=strings(1,1);
total_words_pos=[];
index=1;


%%%%%Count synsets for each hypernym
for i=1:numel(dictionary_corrected)

if(strlength(Synsets(i))>3)
temp_raw=Synsets(i);
temp_raw_categories=extractBetween(temp_raw,'(''',''')');
word_synsets=strings(1,1);
for c=1:numel(temp_raw_categories)
temp_raw_category=temp_raw_categories(c);
temp_raw_category_clean=extractBefore(temp_raw_category,'.');
total_words(index)=temp_raw_category_clean;
word_synsets(c)=temp_raw_category_clean;
total_words_pos(index)=i;
index=index+1;
end
word_synsets(end+1)=extractBefore(strrep(BASIC_SYNSETS{i},"'",""),'.');
Synsets_cell{i}=word_synsets;
end

end


%%%%%built occurrence matrix
wordnet_dictionary=unique(total_words);
word_frequency=zeros(numel(dictionary_corrected),numel(wordnet_dictionary));
for i=1:numel(dictionary_corrected)
word_synsets=Synsets_cell{i};

for c=1:numel(wordnet_dictionary)
temp_mask=sum(strcmp(wordnet_dictionary(c),word_synsets));
word_frequency(i,c)=(temp_mask>0);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%dictionary_corrected(find(word_frequency(:,strcmp(wordnet_dictionary,'measure'))))
%wordnet_dictionary(find(word_frequency(strcmp(dictionary_corrected,'cartridge'),:)>0))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%%%% Fix bigrams
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

classes={...
["artifact","object","instrumentality","device", "matter"]; ....
["social_group", "group", "group_action", "social_event", "organization", "military_unit","person", "adult","male","female","skilled_worker","worker","commissioned_military_officer", "serviceman", "name", "legal_status", "work" ]; ....
["weapon","firearm","gun","projectile","weaponry", "shooting" ]; ....
["body_part","body_covering", "bodily_process", "body_waste", "facial_expression" ]; ....
["feeling", "emotion", "morality"]; ....
["food","fluid", "plant_product" ]; ....
["number", "measure", "definite_quantity", "magnitude"]; ...
["time_period", "season"]; ...
["location", "region", "structure", "facility", "geological_formation", "direction", "street", "boundary", "side" ]; ....
["clothing", "fabric","protective_covering","footwear", "strip", "cloth_covering", "needlework" ];...
["plant"];...
;};

classes_labels={"artifacts", "social", "weapons", "body", "affect", "food", "numbers", "time", "locations", "clothes", "plants" };


gclasses=zeros(numel(dictionary_corrected),1);
for c=1:numel(classes)
temp_classes=classes{c};
temp_mask=zeros(numel(dictionary_corrected),1);
for c2=1:numel(temp_classes)
gclasses(find(word_frequency(:,strcmp(wordnet_dictionary,temp_classes(c2)))))=c;
end
end


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

figure(); hold on;
%text(tsne_coord(gclasses==0,1)+0.45,tsne_coord(gclasses==0,2),dictionary_corrected_bigrams(gclasses==0),'Color',[0.7,0.7,0.7],'Fontsize',6);
%scatter(tsne_coord(gclasses==0,1),tsne_coord(gclasses==0,2),10,[0.9,0.9,0.9],'filled','MarkerFaceAlpha',0.8,'MarkerEdgeAlpha',0.8); 

for c=1:numel(classes)
%text(tsne_coord(gclasses==c,1)+0.45,tsne_coord(gclasses==c,2),dictionary_corrected_bigrams(gclasses==c),'Color',[0.5,0.5,0.5],'Fontsize',6);
scatter(tsne_coord(gclasses==c,1),tsne_coord(gclasses==c,2),50,colorclasses(c,:),'filled','MarkerFaceAlpha',0.8,'MarkerEdgeAlpha',0.8); 
end

axis square
axis off
box off
title('Clusters WordNet')
legend(classes_labels,'Location','bestoutside');



figure(); hold on;
%scatter(tsne_coord(gclasses==0,1),tsne_coord(gclasses==0,2),10,'filled','MarkerFaceColor',[0,0,0],'MarkerFaceAlpha',0.05,'MarkerEdgecolor','none');
for c=1:numel(classes)
scatter(tsne_coord(gclasses==c,1),tsne_coord(gclasses==c,2),50,'filled','MarkerFaceColor',colorclasses(c,:),'MarkerFaceAlpha',1,'MarkerEdgecolor','none');
end

axis square
axis off
box off

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_wordnet_clustering.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end
