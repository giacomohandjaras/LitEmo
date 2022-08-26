clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')

%%%%%Open author's metadata and happiness scoring
authors=load('authors_info_v20220112.mat');
dodds=readtable('HEDO/Hedonometer.csv','Delimiter',',');
dodds_dictionary=table2cell(dodds(:,3));
dodds_dictionary=SNLP_removePunctuation(dodds_dictionary);
dodds_dictionary=SNLP_removeSpaces(dodds_dictionary);
dodds_dictionary=lower(dodds_dictionary);

columns_of_interest=[4]; %happiness
dodds_var=table2array(dodds(1:end,columns_of_interest(:,1)));

words_to_exclude=SNLP_loadWords([SANETOOLBOX,'/diachronic_eng.txt']);
mask_to_exclude=zeros(numel(dodds_dictionary),1);
for w=1:numel(dodds_dictionary)
pos=find(strcmp(words_to_exclude,dodds_dictionary{w}));
if(~isempty(pos)); mask_to_exclude(w)=1; end
end


dodds_dictionary(mask_to_exclude==1)=[];
dodds_var(mask_to_exclude==1,:)=[];

directory_of_txt_documents="../AUTHORS_ENG/";
query = '*.txt';

files = dir(fullfile(directory_of_txt_documents, query));

happiness=cell(numel(files),1);
dodds_words=cell(numel(files),1);
frequency=cell(numel(files),1);

for doc = 1: numel(files)
tic
	file=files(doc);
	currentfilewithdir=strcat(directory_of_txt_documents,file.name);
	[filename]=strsplit(file.name,'.');
	author_pos=find(authors.final_authors==str2num(filename{1}));
	author_sex=authors.final_authors_gender(author_pos);
	
	disp(sprintf('Document %s...',currentfilewithdir));	
	str = extractFileText(currentfilewithdir,'Encoding', 'UTF-8');
	words = strsplit(str, ' ');
	
	happiness_vector=zeros(numel(words),1,'single');
	words_vector=zeros(numel(words),1,'uint16');
	frequency_vector=zeros(numel(dodds_dictionary),1,'uint32');

	for w=1:numel(happiness_vector)
	pos=find(strcmp(dodds_dictionary,words{w}));
	if(~isempty(pos)); pos=pos(1); frequency_vector(pos)=frequency_vector(pos)+1; happiness_vector(w)=dodds_var(pos,1); words_vector(w)=pos; end
	end
	
	happiness{author_pos}=happiness_vector;
	dodds_words{author_pos}=words_vector;
	frequency{author_pos}=frequency_vector;

	disp(sprintf('Mean Valence for author %s: %.3f...',authors.final_authors_name{author_pos}, mean(happiness_vector(happiness_vector>0))));	

toc
end

save('HEDO/sentiment_analysis_dodds_v20220411.mat','authors','happiness','dodds_words','frequency','dodds_dictionary','dodds_var');
	
	
