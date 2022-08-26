clear all
clc

SANETOOLBOX='../SaneNLP_toolbox';
addpath(SANETOOLBOX);

%%%split in bash: split -l 10000 1-00000-of-00001_cleaned_intime
chunks=dir('x*');
timeline=[1719:1:2020];
time_steps=[1719:21:2020];
time_steps(end+1)=2021;

occurrences=cell(numel(time_steps)-1,1);
%%%%%initialize space to avoid out of memory....it's faster then datastore
disp(sprintf('Initialize the space...')); 
N=1856445;
for j=1:numel(time_steps)-1
occurrences{j}=zeros(N,time_steps(j+1)-time_steps(j),'uint32');
end

dictionary=strings(N,1);
occurrences_sum=zeros(N,1,'uint64');
begin_pos=1;

for i=1:numel(chunks)
tic
disp(sprintf('Process chunk %d/%d',i, numel(chunks))); 
dic=SNLP_loadWords(chunks(i).name);
end_pos=size(dic,1);
dictionary(begin_pos:(end_pos+begin_pos-1))=lower(string(dic(1:end,1)));
occurrences_temp=cellfun(@str2num, dic(1:end,2:end));
occurrences_temp=uint32(occurrences_temp);
for j=1:numel(time_steps)-1
mask_temp=(timeline>=time_steps(j) & timeline<time_steps(j+1)); 
occurrences_temp_all=occurrences{j};
occurrences_temp_all(begin_pos:(end_pos+begin_pos-1),:)=occurrences_temp(:,mask_temp);
occurrences{j}=occurrences_temp_all;
end

occurrences_sum(begin_pos:(end_pos+begin_pos-1))=sum(occurrences_temp,2);
begin_pos=begin_pos+end_pos;
toc
end

clear occurrences_temp occurrences_temp_all begin_pos end_pos

disp(sprintf('Remove the puntuaction...')); 
dictionary_cleaned=SNLP_removePunctuation(dictionary);
dictionary_final={};
occurrences_final_pos=[];
dictionary_pos=1;


disp(sprintf('Checking words...')); 
for w=1:numel(dictionary_cleaned)
if(mod(w,100000)==0); disp(sprintf('Processing word %d/%d',w,numel(dictionary_cleaned))); end
current_word=dictionary_cleaned{w};
current_words=strsplit(current_word);
if numel(current_words)>1

for j=1:numel(current_words)
if(isempty(current_words{j})==0)
dictionary_final{dictionary_pos,1}=current_words{j};
occurrences_final_pos(dictionary_pos,1)=w;
dictionary_pos=dictionary_pos+1;
end
end

else
dictionary_final{dictionary_pos,1}=current_word;
occurrences_final_pos(dictionary_pos,1)=w;
dictionary_pos=dictionary_pos+1;
end

end


N2=numel(dictionary_final);
occurrences_final=cell(numel(time_steps)-1,1);
for j=1:numel(time_steps)-1
occurrences_final{j}=zeros(N2,time_steps(j+1)-time_steps(j),'uint32');
end
occurrences_sum_final=zeros(N2,1,'uint64');


disp(sprintf('Generating a new space...')); 
for j=1:numel(time_steps)-1
disp(sprintf('Processing timestep %d/%d',j, numel(time_steps)-1)); 
mask_temp=(timeline>=time_steps(j) & timeline<time_steps(j+1)); 
occurrences_temp_all=occurrences_final{j};
occurrences_temp_all_old=occurrences{j};
for w=1:numel(dictionary_final)
occurrences_temp_all(w,:)=occurrences_temp_all_old(occurrences_final_pos(w),:);
end
occurrences_final{j}=occurrences_temp_all;
end

for w=1:numel(dictionary_final)
occurrences_sum_final(w,:)=occurrences_sum(occurrences_final_pos(w));
end


clear occurrences_final_pos occurrences_temp_all occurrences_temp_all_old dictionary dictionary_cleaned occurrences occurrences_sum j w current_word current_words dictionary_pos


%%%%%the final step, merge similar words 

[dictionary_unique,~,dictionary_unique_index]=unique(dictionary_final);
N3=numel(dictionary_unique);
occurrences_unique=cell(numel(time_steps)-1,1);
for j=1:numel(time_steps)-1
occurrences_unique{j}=zeros(N3,time_steps(j+1)-time_steps(j),'uint32');
end
occurrences_sum_unique=zeros(N3,1,'uint64');


disp(sprintf('Merging simlar words....')); 
for j=1:numel(time_steps)-1
tic
disp(sprintf('Processing timestep %d/%d',j, numel(time_steps)-1)); 
mask_temp=(timeline>=time_steps(j) & timeline<time_steps(j+1)); 
occurrences_temp_all=occurrences_unique{j};
occurrences_temp_all_old=occurrences_final{j};

for i=1:numel(dictionary_unique)
dic_mask=(dictionary_unique_index==i);
occurrences_temp_all(i,:)=sum(occurrences_temp_all_old(dic_mask,:),1);
end
occurrences_unique{j}=occurrences_temp_all;
toc
end


disp(sprintf('Preparing the occurrence vector...')); 
for i=1:numel(dictionary_unique)
dic_mask=(dictionary_unique_index==i);
occurrences_sum_unique(i,:)=sum(occurrences_sum_final(dic_mask));
end


clearvars -except keepVariables occurrences_unique dictionary_unique occurrences_sum_unique timeline time_steps

[occurrences_sorted,occurrences_index]=sort(occurrences_sum_unique,'descend');
dictionary_final=dictionary_unique(occurrences_index);

disp(sprintf('Resorting data...')); 
for j=1:numel(time_steps)-1
occurrences_temp_all=occurrences_unique{j};
occurrences_temp_all=occurrences_temp_all(occurrences_index,:);
occurrences_unique{j}=occurrences_temp_all;
end

occurrences_final=occurrences_unique;
clear dictionary_unique occurrences_unique occurrences_index j  occurrences_temp_all occurrences_sum_unique


disp(sprintf('Creating the occurrences in time...')); 
occurrences_intime=zeros(numel(timeline),1);
for j=1:numel(time_steps)-1
occurrences_temp_all=occurrences_final{j};
mask_temp=(timeline>=time_steps(j) & timeline<time_steps(j+1)); 
occurrences_intime(find(mask_temp))=sum(occurrences_temp_all,1);
end


clear occurrences_temp_all j mask_temp


save('google_fiction2020_v20220219_intime.mat');

