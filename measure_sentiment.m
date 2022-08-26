clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')

%%%%%adesso apriamo le informazioni sugli autori
authors=load('authors_info_v20220112.mat');
warriner=readtable('WARRINER/BRM-emot-submit.csv','Delimiter',',');
warriner_dictionary=table2cell(warriner(:,2));
warriner_dictionary=SNLP_removeSpaces(warriner_dictionary);

columns_of_interest=[12,15;18,21]; %valence, arousal across men and women
warriner_var_male=table2array(warriner(1:end,columns_of_interest(:,1)));
warriner_var_female=table2array(warriner(1:end,columns_of_interest(:,2)));

words_to_exclude=SNLP_loadWords([SANETOOLBOX,'/diachronic_eng.txt']);
mask_to_exclude=zeros(numel(warriner_dictionary),1);
for w=1:numel(warriner_dictionary)
pos=find(strcmp(words_to_exclude,warriner_dictionary{w}));
if(~isempty(pos)); mask_to_exclude(w)=1; end
end


warriner_dictionary(mask_to_exclude==1)=[];
warriner_var_male(mask_to_exclude==1,:)=[];
warriner_var_female(mask_to_exclude==1,:)=[];

directory_of_txt_documents="../AUTHORS_ENG/";
query = '*.txt';

files = dir(fullfile(directory_of_txt_documents, query));

valence=cell(numel(files),1);
arousal=cell(numel(files),1);
warriner_words=cell(numel(files),1);
frequency=cell(numel(files),1);

for doc = 1: numel(files)
tic
	file=files(doc);
	currentfilewithdir=strcat(directory_of_txt_documents,file.name);
	[filename]=strsplit(file.name,'.');
	author_pos=find(authors.final_authors==str2num(filename{1}));
	author_sex=authors.final_authors_gender(author_pos);
	if (author_sex==0); warriner_var=warriner_var_male; else warriner_var=warriner_var_female; end
	
	disp(sprintf('Processo il documento %s...',currentfilewithdir));	
	str = extractFileText(currentfilewithdir,'Encoding', 'UTF-8');
	words = strsplit(str, ' ');
	
	valence_vector=zeros(numel(words),1,'single');
	arousal_vector=zeros(numel(words),1,'single');
	words_vector=zeros(numel(words),1,'uint16');
	frequency_vector=zeros(numel(warriner_dictionary),1,'uint32');

	for w=1:numel(valence_vector)
	pos=find(strcmp(warriner_dictionary,words{w}));
	if(~isempty(pos)); pos=pos(1); frequency_vector(pos)=frequency_vector(pos)+1; valence_vector(w)=warriner_var(pos,1); arousal_vector(w)=warriner_var(pos,2); words_vector(w)=pos; end
	end
	
	valence{author_pos}=valence_vector;
	arousal{author_pos}=arousal_vector;
	warriner_words{author_pos}=words_vector;
	frequency{author_pos}=frequency_vector;

	disp(sprintf('Mean Valence for author %s: %.3f...',authors.final_authors_name{author_pos}, mean(valence_vector(valence_vector>0))));	

toc
end

save('WARRINER/sentiment_analysis_v20220329.mat','authors','valence','arousal','warriner_words','frequency','warriner_dictionary','warriner_var_male','warriner_var_female');
	
	
