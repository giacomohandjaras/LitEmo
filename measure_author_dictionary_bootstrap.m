clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')
addpath('additional_functions/Colormaps')

save_derivatives=1;

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;

male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;


continent_colors = [...
102,194,165
252,141,98
141,160,203
231,138,195
166,216,84
255,217,47 ]./255; 

draw_titles=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24+2;

%%%%%Open author information
authors=load('authors_info_v20220112.mat');

directory_of_txt_documents="../AUTHORS_ENG/";
query = '*.txt';
max_bootstrap=10000; %%%8k is the shortest author collected
boot_iter=100;


files = dir(fullfile(directory_of_txt_documents, query));
unique_words=nan(numel(files),boot_iter);
unique_words_id=nan(numel(files),1);

doc=1;
for file = files'
tic
	currentfilewithdir=strcat(directory_of_txt_documents,file.name);
	[filename]=strsplit(file.name,'.');
	unique_words_id(doc)=str2num(filename{1});

	disp(sprintf('Processing document %s...',currentfilewithdir));	

	str = extractFileText(currentfilewithdir,'Encoding', 'UTF-8');
	documents = tokenizedDocument(str);
	tokens=string(documents);
	token_num=numel(tokens);
	if(token_num>max_bootstrap)
	for boot=1:boot_iter
	randpos=randi(token_num-max_bootstrap);
	str_boot=tokens(randpos:(randpos+max_bootstrap-1));
	document_boot = tokenizedDocument(strjoin(str_boot));
	unique_tokens=numel(document_boot.Vocabulary);
	unique_words(doc,boot)=unique_tokens;
	end
	else
	disp(sprintf('The document has %d unique words (less than the defined threshold %d): bootstrap is non feasible!',token_num, max_bootstrap));	
	unique_tokens=numel(documents.Vocabulary);
	unique_words(doc,:)=unique_tokens;
	end
	
doc=doc+1;
toc
end

%%%%%Re-sort all the data according to covariates ID
final_unique_words=nan(size(authors.final_authors));

for a=1:numel(authors.final_authors)
pos=find(authors.final_authors(a)==unique_words_id);
final_unique_words(a)=nanmean(unique_words(pos,:));
end


%save('ALL_TERMS/vocabulary_size_bootstrap_v20220203.mat','authors','final_unique_words','max_bootstrap');
load('ALL_TERMS/vocabulary_size_bootstrap_v20220203.mat');

disp(sprintf('Unique words with bootstrap (chunk %d), Male: %d, std: %d    Female: %d, std: %d ',max_bootstrap,round(mean(final_unique_words(authors.final_authors_gender==0))),round(std(final_unique_words(authors.final_authors_gender==0))), round(mean(final_unique_words(authors.final_authors_gender==1))),round(std(final_unique_words(authors.final_authors_gender==1)))));
[p,h]=ranksum(final_unique_words(authors.final_authors_gender==0),final_unique_words(authors.final_authors_gender==1));
disp(sprintf('Difference M-F: %d, p=%.8f ',round(mean(final_unique_words(authors.final_authors_gender==0)))-round(mean(final_unique_words(authors.final_authors_gender==1))),p));


unique_words_male=final_unique_words(authors.final_authors_gender==0);
unique_words_female=final_unique_words(authors.final_authors_gender==1);

figure()
histogram(unique_words_male,'BinWidth',75,'FaceColor',male_color,'FaceAlpha',male_transp,'Normalization','probability','edgecolor','none');
hold on
histogram(unique_words_female,'BinWidth',75,'FaceColor',female_color,'FaceAlpha',female_transp,'Normalization','probability','edgecolor','none');
if(draw_titles==1); title(['Vocabulary (bootsrap) size for male and female authors, p=', num2str(p,'%.6f') ]); end
xlabel('unique words by author in 10k-long excerpts','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('probability','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
%legend({'Male','Female'},'Location','northeast','FontSize',legend_fontsize,'FontName','Arial');
xticks([800:300:3300])
xticklabels(strsplit(num2str([800:300:3300]/1000,' %.1fk ')))
xlim([800,3300])

xtickangle(45)
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])
pbaspect([1.5,1,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/measure_author_dictionary_bootstrap.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end

