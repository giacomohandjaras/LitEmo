%%%%%This script combine multiple books from the same author in an unique txt document
clear all
clc

%%%Open informations related to books and authors
books_info='corpus_eng_v20210617.csv';
books_dir='../BOOKS_ENG/';
books_suffix='_cleaned.txt';
authors_dir='../AUTHORS_ENG/';


books_data=read_mixed_csv(books_info, ',');

authors_id=cellfun(@str2num, books_data(1:end,5));
authors_gender=cellfun(@str2num, books_data(1:end,2));
authors_pubyear=cellfun(@str2num, books_data(1:end,3));
authors_continent=cellfun(@str2num, books_data(1:end,4));
authors_translated=cellfun(@str2num, books_data(1:end,8));
books_id=cellfun(@str2num, books_data(1:end,7));
authors_country= books_data(1:end,1);


final_authors=unique(authors_id);
final_authors_count=numel(final_authors);

final_authors_gender=nan(final_authors_count,1);
final_authors_pubyear=nan(final_authors_count,1);
final_authors_continent=nan(final_authors_count,1);
final_authors_country=cell(final_authors_count,1);
final_authors_translated=nan(final_authors_count,1);


for i=1:final_authors_count
disp(sprintf('#########################'));
author_mask=authors_id==final_authors(i);
final_authors_gender(i)=mean(authors_gender(author_mask));
final_authors_pubyear(i)=round(mean(authors_pubyear(author_mask)));
final_authors_continent(i)=mean(authors_continent(author_mask));
final_authors_translated(i)=mean(authors_translated(author_mask));
temp=authors_country(author_mask);
final_authors_country(i)=temp(1);
clear temp;

%%%%%Fix authors publishing in multiple languages
final_authors_translated(final_authors_translated<1)=0;


temp_books=books_id(author_mask);
books_str=[];
for l=1:numel(temp_books)
currentfilewithdir=strcat(books_dir,num2str(temp_books(l)),books_suffix);
disp(sprintf('Process documents %s',currentfilewithdir));
str = extractFileText(currentfilewithdir,'Encoding', 'UTF-8');
books_str=strjoin([books_str, str]);
end

currentfilewithdir_tosave=strcat(authors_dir,num2str(final_authors(i)),'.txt');
fid = fopen(currentfilewithdir_tosave,'wt');
fprintf(fid, '%s',books_str);
fclose(fid);

disp(sprintf('Saving author %s',currentfilewithdir_tosave));
disp(sprintf('Publication year %d',final_authors_pubyear(i)));
disp(sprintf('Sex %d',final_authors_gender(i)));
disp(sprintf('Country %s',final_authors_country{i}));
disp(sprintf('#########################'));
pause(1);
end
