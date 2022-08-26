clear all
clc

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);

table=readtable('corpus_v20220112.xlsx','Range', 'A1:M2274');


authors_id=table.AUT_ID;
books_id=table.TXT_ENG;

authors_gender=table.GENDER;
authors_pubyear=table.PUB_YEAR;
authors_continent=table.CONT;
authors_country=table.NAT;
authors_translated=table.TRAN;
authors_surname=table.SURNAME;
authors_name=table.NAME;
authors_nobel=table.NOBEL;
authors_prizes=table.OTHER_PRIZES;

%%%%%Initialize the variables for the list of authors
final_authors=unique(authors_id);
final_authors_count=numel(final_authors);

final_authors_gender=nan(final_authors_count,1);
final_authors_pubyear=nan(final_authors_count,1);
final_authors_continent=nan(final_authors_count,1);
final_authors_country=cell(final_authors_count,1);
final_authors_name=cell(final_authors_count,1);
final_authors_translated=nan(final_authors_count,1);
final_authors_nobel=nan(final_authors_count,1);
final_authors_prizes=nan(final_authors_count,1);


for i=1:final_authors_count
author_mask=authors_id==final_authors(i);
final_authors_gender(i)=mean(authors_gender(author_mask));
final_authors_pubyear(i)=round(mean(authors_pubyear(author_mask)));
final_authors_continent(i)=mean(authors_continent(author_mask));
final_authors_translated(i)=round(mean(authors_translated(author_mask))); %%%Attention here! Few authors (<10) have books in ENG and in another languages: in this case, the language of the author is defined on the basis of the max number of english vs translated documents
final_authors_nobel(i)=max(authors_nobel(author_mask));
final_authors_prizes(i)=sum(authors_prizes(author_mask));
temp=authors_country(author_mask);
final_authors_country(i)=temp(1);
temp1=authors_surname(author_mask);
temp2=authors_name(author_mask);
final_authors_name(i)=strcat(temp1{1},{' '},temp2{1});
clear temp temp1 temp2
end


save('authors_info_v20220112.mat','authors_id','books_id','final_authors','final_authors_count','final_authors_gender','final_authors_pubyear','final_authors_continent','final_authors_country','final_authors_name','final_authors_translated', 'final_authors_nobel','final_authors_prizes');

%%%%%Write a txt with the ID of authors in chronological order: it will be used by word2vec to handle curriculum learning

[~,temp_indx]=sort(final_authors_pubyear,'ascend');
temp_final_authors=final_authors(temp_indx);
SNLP_saveWords('../id_authors_curriculum_learning_v20220112.txt', string(temp_final_authors));

temp_final_authors_gender=final_authors_gender(temp_indx);
temp_final_authors_male=temp_final_authors(temp_final_authors_gender==0);
SNLP_saveWords('../id_authors_male_curriculum_learning_v20220112.txt', string(temp_final_authors_male));

temp_final_authors_gender=final_authors_gender(temp_indx);
temp_final_authors_female=temp_final_authors(temp_final_authors_gender==1);
SNLP_saveWords('../id_authors_female_curriculum_learning_v20220112.txt', string(temp_final_authors_female));



