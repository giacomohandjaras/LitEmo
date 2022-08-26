clear all
clc

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);

directory_of_txt_documents="../AUTHORS_ENG/";

%dictionary=SNLP_loadWords('ALL_TERMS/all_terms_v20220112.txt');
dictionary=SNLP_loadWords('LIWC/LIWC2015_English_pos_nodiachronic.txt');
%dictionary=SNLP_loadWords('LIWC/LIWC2015_English_neg_nodiachronic.txt');

dic=dictionary(1:end,1);

query = '*.dic';
files = dir(fullfile(directory_of_txt_documents, query));

results_singlebook_general=nan(numel(files),11);
results_singlebook_raw=nan(numel(files),numel(dic));
results_singlebook_raw_ranks=nan(numel(files),numel(dic));

book=1;
for file = files'
	tic
	currentfilewithdir=strcat(directory_of_txt_documents,file.name);
	
	[counts, words,total_words, unique_words, unique_ranks,max_ranks,min_ranks,ranks]=SNLP_getOccurrence(currentfilewithdir,dic);
	
	[filename]=strsplit(file.name,'.');
	
	results_singlebook_raw(book,:)=counts;
	results_singlebook_raw_ranks(book,:)=ranks;

	book_id=str2num(filename{1});
	
	results_singlebook_general(book,1)=book_id;
	results_singlebook_general(book,2)=sum(counts);  %%%Total number of tokens of interest (from the dictionary dic) present in the document 
	results_singlebook_general(book,3)=total_words;  %%%All the tokens in the document
	results_singlebook_general(book,4)=unique_words;  %%%Unique tokens (vocabulary) of the document
	results_singlebook_general(book,5)=(sum(counts)./total_words)*100;  %%% % of coverage related to the dictionary dic
	results_singlebook_general(book,6)=(sum(counts>0)./unique_words)*100;  %%% % of coverage of unique tokens related to the dictionary dic
	results_singlebook_general(book,7)=min(ranks); % the min rank of the dictionary (i.e., 1)
	results_singlebook_general(book,8)=max(ranks); %il rango massimo nel dizionario  (i.e., since there are many ties, this number is usually less than sum(counts>0))
	results_singlebook_general(book,9)=unique_ranks; %the numner of ranks
	results_singlebook_general(book,10)=min_ranks; %the min rank of the document (i.e., 1)
	results_singlebook_general(book,11)=max_ranks; %the max rank of the unique words in the document

	disp(sprintf('Document %s...',currentfilewithdir));	
	book=book+1;
	toc
end


%save('ALL_TERMS/all_terms_v20220112.mat', 'dictionary', 'results_singlebook_general', 'results_singlebook_raw','results_singlebook_raw_ranks');
save('LIWC/LIWC_eng_pos_nodiachronic.mat', 'dictionary', 'results_singlebook_general', 'results_singlebook_raw','results_singlebook_raw_ranks');
%save('LIWC/LIWC_eng_neg_nodiachronic.mat', 'dictionary', 'results_singlebook_general', 'results_singlebook_raw','results_singlebook_raw_ranks');

