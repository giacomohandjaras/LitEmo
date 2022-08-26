clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/borders')
addpath('additional_functions/export_fig')
addpath('additional_functions/Colormaps')

DATA=load('ALL_TERMS/all_terms_v20220112.mat');
covariates=load('authors_info_v20220112.mat');

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;

male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

continent_colors = [...
141,211,199
255,255,179
190,186,218
251,128,114
128,177,211
253,180,98]./255; 

save_derivatives=1;
draw_titles=0;
draw_legend=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Very basic stats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp(sprintf('Total authors: %d, male: %d, female:%d',numel(covariates.final_authors),sum(covariates.final_authors_gender==0), sum(covariates.final_authors_gender==1)));

books_for_author=nan(numel(covariates.final_authors),1);
for i=1:numel(covariates.final_authors)
books_for_author(i)=numel(find(covariates.authors_id==covariates.final_authors(i)));
end
disp(sprintf('Average books per author: %.2f, std:%.2f, min: %d, max:%d',mean(books_for_author),std(books_for_author),min(books_for_author),max(books_for_author)));

authors_id_unique_male=covariates.final_authors(covariates.final_authors_gender==0);
books_male=nan(numel(authors_id_unique_male),1);
for i=1:numel(books_male)
books_male(i)=numel(find(covariates.authors_id==authors_id_unique_male(i)));
end
disp(sprintf('Average books per male author: %.2f, std:%.2f, min: %d, max:%d',mean(books_male),std(books_male),min(books_male),max(books_male)));

authors_id_unique_female=covariates.final_authors(covariates.final_authors_gender==1);
books_female=nan(numel(authors_id_unique_female),1);
for i=1:numel(books_female)
books_female(i)=numel(find(covariates.authors_id==authors_id_unique_female(i)));
end
disp(sprintf('Average books per female author: %.2f, std:%.2f, min: %d, max:%d',mean(books_female),std(books_female),min(books_female),max(books_female)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Histogram authors by time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure()
histogram(covariates.final_authors_pubyear(covariates.final_authors_gender==0),'BinWidth',10,'FaceColor',male_color,'FaceAlpha',male_transp,'edgecolor','none');
hold on
histogram(covariates.final_authors_pubyear(covariates.final_authors_gender==1),'BinWidth',10,'FaceColor',female_color_transp,'FaceAlpha',1,'edgecolor','none');
if(draw_titles==1); title('Authors in the corpus','FontSize',legend_fontsize,'FontName','Arial'); end
xlabel('historical period','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('authors','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
if(draw_legend==1); legend({'Male','Female'},'Location','northwest','FontSize',legend_fontsize,'FontName','Arial'); end
xticks([1700:50:2020])
xticklabels([1700:50:2020]);
xtickangle(45)
yticks([0:50:200]);
yticklabels([0:50:200]);
xlim([1700,2020])
ylim([0,200])
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])
pbaspect([1.5,0.95,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_authors_intime.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Pie chart authors by continent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

covariates.final_authors_continent_male=covariates.final_authors_continent(covariates.final_authors_gender==0);
covariates.final_authors_continent_female=covariates.final_authors_continent(covariates.final_authors_gender==1);

C=[];
C(1)=sum((covariates.final_authors_continent==1)/numel(covariates.final_authors_continent));
C(2)=sum((covariates.final_authors_continent==2)/numel(covariates.final_authors_continent));
C(3)=sum((covariates.final_authors_continent==3)/numel(covariates.final_authors_continent));
C(4)=sum((covariates.final_authors_continent==4)/numel(covariates.final_authors_continent));
C(5)=sum((covariates.final_authors_continent==5)/numel(covariates.final_authors_continent));
C(6)=sum((covariates.final_authors_continent==6)/numel(covariates.final_authors_continent));
L = {'Europe','North America','South America','Asia', 'Africa', 'Oceania' };
offset_text_x=[-0.5,0,-0.08,-0.02,0.05,-0.03];
offset_text_y=[0,0.01,-0.05,-0.05,-0.05,-0.0];
figure(); 
H=pie(C);
H(2).String="";H(4).String="";H(6).String="";H(8).String="";H(10).String="";H(12).String="";
if(draw_titles==1);  title('Continent of authors','FontSize',legend_fontsize,'FontName','Arial'); end
T = H(strcmpi(get(H,'Type'),'text'));
P = cell2mat(get(T,'Position'));
set(T,{'Position'},num2cell(P*0.5,2))
set(H(2:2:end),'FontSize',tick_fontsize,'FontName','Arial');
text(P(:,1)+offset_text_x',P(:,2)+offset_text_y',L(:),'Fontsize',label_fontsize,'FontName','Arial');
ax = gca(); 
ax.Colormap = continent_colors;
xlim([-1.35,1.35]);
ylim([-1.35,1.35]);
axis square
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_authors_continents.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Pie chart MALE authors by continent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

C=[];
C(1)=sum((covariates.final_authors_continent_male==1)/numel(covariates.final_authors_continent_male));
C(2)=sum((covariates.final_authors_continent_male==2)/numel(covariates.final_authors_continent_male));
C(3)=sum((covariates.final_authors_continent_male==3)/numel(covariates.final_authors_continent_male));
C(4)=sum((covariates.final_authors_continent_male==4)/numel(covariates.final_authors_continent_male));
C(5)=sum((covariates.final_authors_continent_male==5)/numel(covariates.final_authors_continent_male));
C(6)=sum((covariates.final_authors_continent_male==6)/numel(covariates.final_authors_continent_male));
L = {'Europe','North America','South America','Asia', 'Africa', 'Oceania' };
offset_text_x=[-0.5,0,-0.08,-0.02,0.05,-0.03];
offset_text_y=[0,0.01,-0.05,-0.05,-0.05,-0.0];
figure(); 
H=pie(C);
if(draw_titles==1);  title('Continent of male authors','FontSize',legend_fontsize,'FontName','Arial'); end
T = H(strcmpi(get(H,'Type'),'text'));
P = cell2mat(get(T,'Position'));
set(T,{'Position'},num2cell(P*0.5,2))
set(H(2:2:end),'FontSize',tick_fontsize,'FontName','Arial');
text(P(:,1)+offset_text_x',P(:,2)+offset_text_y',L(:),'Fontsize',label_fontsize,'FontName','Arial');
ax = gca(); 
ax.Colormap = continent_colors;
axis square
drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Pie chart MALE authors by continent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

C=[];
C(1)=sum((covariates.final_authors_continent_female==1)/numel(covariates.final_authors_continent_female));
C(2)=sum((covariates.final_authors_continent_female==2)/numel(covariates.final_authors_continent_female));
C(3)=sum((covariates.final_authors_continent_female==3)/numel(covariates.final_authors_continent_female));
C(4)=sum((covariates.final_authors_continent_female==4)/numel(covariates.final_authors_continent_female));
C(5)=sum((covariates.final_authors_continent_female==5)/numel(covariates.final_authors_continent_female));
C(6)=sum((covariates.final_authors_continent_female==6)/numel(covariates.final_authors_continent_female));
L = {'Europe','North America','South America','Asia', 'Africa', 'Oceania' };
offset_text_x=[-0.5,0,-0.08,-0.02,0.05,-0.03];
offset_text_y=[0,0.01,-0.05,-0.05,-0.05,-0.0];
figure(); 
H=pie(C);
if(draw_titles==1);  title('Continent of female authors','FontSize',legend_fontsize,'FontName','Arial'); end
T = H(strcmpi(get(H,'Type'),'text'));
P = cell2mat(get(T,'Position'));
set(T,{'Position'},num2cell(P*0.5,2))
set(H(2:2:end),'FontSize',tick_fontsize,'FontName','Arial');
text(P(:,1)+offset_text_x',P(:,2)+offset_text_y',L(:),'Fontsize',label_fontsize,'FontName','Arial');
ax = gca(); 
ax.Colormap = continent_colors;
axis square
drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Worldmap of authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

covariates.final_authors_country_male=covariates.final_authors_country(covariates.final_authors_gender==0);
covariates.final_authors_country_female=covariates.final_authors_country(covariates.final_authors_gender==1);

countries=unique(covariates.final_authors_country);
countries_freq=nan(numel(countries),1);

for i=1:numel(countries)
countries_freq(i)=sum(strcmp(covariates.final_authors_country,countries(i)));
end


colors_to_map=viridis;
%colormap(viridis)
colors=log(countries_freq)+1;
colors=tiedrank(colors);
colors=round((colors./max(colors))*256);

figure();
borders('countries','Color',[0.7,0.7,0.7])
axis off
for i=1:numel(countries_freq)
borders(countries{i},'facecolor',colors_to_map(colors(i),:))
end
if(draw_titles==1);  title('Country of origin of authors','FontSize',legend_fontsize,'FontName','Arial'); end
pbaspect([1.7,1,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_authors_worldmap.png');
export_fig(image_filename,'-m10','-nocrop', '-transparent','-silent');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Worldmap of male authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

countries=unique(covariates.final_authors_country_male);
countries_freq=nan(numel(countries),1);

for i=1:numel(countries)
countries_freq(i)=sum(strcmp(covariates.final_authors_country_male,countries(i)));
end

colors_to_map=viridis;
%colormap(viridis)
colors=log(countries_freq)+1;
colors=tiedrank(colors);
colors=round((colors./max(colors))*256);

figure();
borders('countries','Color',[0.7,0.7,0.7])
axis off
for i=1:numel(countries_freq)
borders(countries{i},'facecolor',colors_to_map(colors(i),:))
end
if(draw_titles==1);  title('Country of origin of male authors','FontSize',legend_fontsize,'FontName','Arial'); end
pbaspect([1.7,1,1])
drawnow




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Worldmap of female authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

countries=unique(covariates.final_authors_country_female);
countries_freq=nan(numel(countries),1);

for i=1:numel(countries)
countries_freq(i)=sum(strcmp(covariates.final_authors_country_female,countries(i)));
end

colors_to_map=viridis;
%colormap(viridis)
colors=log(countries_freq)+1;
colors=tiedrank(colors);
colors=round((colors./max(colors))*256);

figure();
borders('countries','Color',[0.7,0.7,0.7])
axis off
for i=1:numel(countries_freq)
borders(countries{i},'facecolor',colors_to_map(colors(i),:))
end
if(draw_titles==1);  title('Country of origin of female authors','FontSize',legend_fontsize,'FontName','Arial'); end
pbaspect([1.7,1,1])
drawnow




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Variables in results_singlebook_general; #1 BOOK (or AUTHOR) ID, #2 TOTAL WORDS in the dictionary, #3 TOTAL WORDS, #4 TOTAL UNIQUE WORDS, #5 % of coverage of the dictionary #6 % coverage of the dictionary considering unique ords #7 min rank of the dictionary #8 max rank of the dictionary 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

authors=numel(covariates.final_authors);
data_fixed=nan(size(DATA.results_singlebook_general));

authors_gender=covariates.final_authors_gender;
authors_year=covariates.final_authors_pubyear;

%%%%%Re-sort all the data according to covariates ID
for a=1:authors
author_pos=find(DATA.results_singlebook_general(:,1)==covariates.final_authors(a));
data_fixed(a,:)=DATA.results_singlebook_general(author_pos,:);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Vocabulary size
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

unique_words_male=data_fixed(authors_gender==0,4);
unique_words_female=data_fixed(authors_gender==1,4);
disp(sprintf('Vocabulary size,  males: %d, std: %d    females: %d, std: %d ',round(mean(unique_words_male)),round(std(unique_words_male)), round(mean(unique_words_female)),round(std(unique_words_female))));
[p,h]=ranksum(unique_words_male,unique_words_female);
disp(sprintf('Difference: %d, p=%.8f ',round(mean(unique_words_male))-round(mean(unique_words_female)),p));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Histogram of unique words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure()
histogram(unique_words_male,'BinWidth',1000,'FaceColor',male_color,'FaceAlpha',male_transp,'Normalization','probability','edgecolor','none');
hold on
histogram(unique_words_female,'BinWidth',1000,'FaceColor',female_color,'FaceAlpha',female_transp,'Normalization','probability','edgecolor','none');
if(draw_titles==1); title(['Vocabulary size for male and female authors, p=', num2str(p,'%.6f') ]); end
xlabel('unique words by author','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('probability','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
if(draw_legend==1); legend({'Male','Female'},'Location','northeast','FontSize',legend_fontsize,'FontName','Arial'); end
xticks([2000:4000:38000])
xticklabels(strsplit(num2str([2000:4000:38000]/1000,' %dk ')))
xlim([1000,38000])

xtickangle(45)
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])
pbaspect([1.5,0.95,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_vocabulary.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Total words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

words_male=data_fixed(authors_gender==0,3);
words_female=data_fixed(authors_gender==1,3);
disp(sprintf('Total words, males: %d, std: %d    females: %d, std: %d ',round(mean(words_male)),round(std(words_male)), round(mean(words_female)),round(std(words_female))));
[p,h]=ranksum(words_male,words_female);
disp(sprintf('Difference: %d, p=%.8f ',round(mean(words_male))-round(mean(words_female)),p));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Histogram of total words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure()
histogram(words_male,'BinWidth',40000,'FaceColor',male_color,'FaceAlpha',male_transp,'Normalization','probability','edgecolor','none');
hold on
histogram(words_female,'BinWidth',40000,'FaceColor',female_color,'FaceAlpha',female_transp,'Normalization','probability','edgecolor','none');
if(draw_titles==1); title(['Words used by male and female authors, p=', num2str(p,'%.6f') ]); end
xlabel('words by author','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('probability','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
if(draw_legend==1); legend({'Male','Female'},'Location','northeast','FontSize',legend_fontsize,'FontName','Arial'); end
xticks([0:200000:2000000])
xticklabels(strsplit(num2str([0:200000:2000000]/1000,' %dk ')))
xlim([0,2000000])

xtickangle(45)
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])
pbaspect([1.5,0.95,1])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_wordcount.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%HEAPS' law
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model_heap= fittype('K*x^b');

rng(16576);

options=fitoptions('Method','linearLeastSquares'); 
%options.MaxIter    = 100000;
options.Robust='Off'; 
bootstrap_iter=100; 

warning off
Xdata=data_fixed(authors_gender==1,3);
Ydata=data_fixed(authors_gender==1,4);
f_female_b=nan(bootstrap_iter,1);
f_female_K=nan(bootstrap_iter,1);
f_female_r=nan(bootstrap_iter,1);
[~,bootsam] = bootstrp(bootstrap_iter,[],[1:numel(Xdata)]);
for boot=1:bootstrap_iter
Xdata_boot=Xdata(bootsam(:,boot));
Ydata_boot=Ydata(bootsam(:,boot));
[f_female_boot, r_female_boot] = fit(Xdata_boot,Ydata_boot,model_heap,options);
f_female_K(boot)=f_female_boot.K;
f_female_b(boot)=f_female_boot.b;
f_female_r(boot)=r_female_boot.adjrsquare;
end


Xdata=data_fixed(authors_gender==0,3);
Ydata=data_fixed(authors_gender==0,4);
f_male_b=nan(bootstrap_iter,1);
f_male_K=nan(bootstrap_iter,1);
f_male_r=nan(bootstrap_iter,1);
[~,bootsam] = bootstrp(bootstrap_iter,[],[1:numel(Xdata)]);
for boot=1:bootstrap_iter
Xdata_boot=Xdata(bootsam(:,boot));
Ydata_boot=Ydata(bootsam(:,boot));
[f_male_boot, r_male_boot] = fit(Xdata_boot,Ydata_boot,model_heap,options);
f_male_K(boot)=f_male_boot.K;
f_male_b(boot)=f_male_boot.b;
f_male_r(boot)=r_male_boot.adjrsquare;
end


disp(sprintf('K MALE:%.3f SE:%.3f; K FEMALE:%.3f SE:%.3f',mean(f_male_K),std(f_male_K),mean(f_female_K),std(f_female_K)));
disp(sprintf('b MALE:%.3f SE:%.3f; b FEMALE:%.3f SE:%.3f',mean(f_male_b),std(f_male_b),mean(f_female_b),std(f_female_b)));
disp(sprintf('Full-model adjusted-R2 MALE:%.3f FEMALE:%.3f ',mean(f_male_r),mean(f_female_r)));


figure(); hold on;

starting_min=min([min(data_fixed(authors_gender==0,3)),min(data_fixed(authors_gender==1,3))]);
ending_max=max([max(data_fixed(authors_gender==0,3)),max(data_fixed(authors_gender==1,3))]);

a=scatter(data_fixed(authors_gender==0,3),data_fixed(authors_gender==0,4),40, 'MarkerFaceColor', male_color, 'MarkerEdgeColor', 'none','MarkerFaceAlpha',male_transp);
b=scatter(data_fixed(authors_gender==1,3),data_fixed(authors_gender==1,4),40,  'MarkerFaceColor', female_color, 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha',female_transp);

avg_effect=(starting_min:10:ending_max);
plot(avg_effect,[(avg_effect.^mean(f_male_b))*mean(f_male_K)], 'Color',[male_color,male_transp] ,'LineStyle','--','LineWidth',2)
plot(avg_effect,[(avg_effect.^mean(f_female_b))*mean(f_female_K)], 'Color',[female_color,female_transp],'LineStyle','--','LineWidth',2)

if(draw_legend==1);
[~, lgd]=legend([a,b],{'Male','Female'},'Location','southeast','FontSize',legend_fontsize,'FontName','Arial');
lgd_markers=findobj(lgd, 'type', 'Patch');
lgd_markers(1).MarkerSize=16;
lgd_markers(2).MarkerSize=16;
lgd_markers(1).MarkerFaceColor=male_color_transp;
lgd_markers(2).MarkerFaceColor=female_color_transp;
end

axis square
pbaspect([0.95,0.95,1])

if(draw_titles==1); title('Heaps'' Law'); end
xlabel('words by author','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('unique words by author','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
xticks([0:200000:2000000])
xticklabels(strsplit(num2str([0:200000:2000000]/1000,' %dk ')))
xtickangle(45)
yticks([2000:4000:38000])
yticklabels(strsplit(num2str([2000:4000:38000]/1000,' %dk ')))

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])

xlim([1000,2000000])
ylim([1000,38000])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_heapslaw.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Zipf's law
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

directory_of_txt_documents='../AUTHORS_ENG/';
data_zipf=cell(authors,1);
for a=1:authors
filename_author=[directory_of_txt_documents,num2str(covariates.final_authors(a)),'.dic'];
disp(sprintf('Open dictionary file %s...',filename_author));
[author_dictionary,author_occurrences]=SNLP_loadDictionary(filename_author);
author_dictionary_freq=(author_occurrences./sum(author_occurrences))*1E6;
data_zipf{a}=author_dictionary_freq;
end

%%%%See References:
%%%%Moreno-Sánchez, I., Font-Clos, F., & Corral, Á. (2016). Large-scale analysis of Zipf’s law in English texts. PloS one, 11(1), e0147073.
%%%%Piantadosi, S. T. (2014). Zipf’s word frequency law in natural language: A critical review and future directions. Psychonomic bulletin & review, 21(5), 1112-1130.
%model_zipf = fittype('1/((x+b)^a)'); % Mandelbrot's
%model_zipf = fittype('(1/(x^(a-1)))-(1/((n+1)^(a-1)))'); % optimized for english plosONE
model_zipf = fittype('b/((x)^a)'); % original Zipf's

options=fitoptions('Method','linearLeastSquares'); 
options.Robust='Off';  
warning off

zipf_results=nan(authors,3);
for a=1:authors
author_dictionary=data_zipf{a};
author_dictionary_norm=author_dictionary;
rank_author=tiedrank(author_dictionary*-1);
mask=log(rank_author)<=10 & log(rank_author)>=2;
author_dictionary_norm_sel=author_dictionary_norm(mask);
rank_author_sel=rank_author(mask);

[f, r] = fit(rank_author_sel,author_dictionary_norm_sel,model_zipf,options);
zipf_results(a,1)=f.a;
zipf_results(a,2)=f.b;
zipf_results(a,3)=r.adjrsquare;
end


zipf_exp_female=zipf_results(authors_gender==1,1);
zipf_scal_female=zipf_results(authors_gender==1,2);
zipf_r2_female=zipf_results(authors_gender==1,3);

zipf_exp_male=zipf_results(authors_gender==0,1);
zipf_scal_male=zipf_results(authors_gender==0,2);
zipf_r2_male=zipf_results(authors_gender==0,3);


[zipf_exp_female_boot] = bootstrp(100,@mean,zipf_exp_female);
disp(sprintf('FEMALE alpha: %.3f SE: %.3f',mean(zipf_exp_female_boot),std(zipf_exp_female_boot)));
[zipf_exp_male_boot] = bootstrp(100,@mean,zipf_exp_male);
disp(sprintf('MALE alpha: %.3f SE: %.3f',mean(zipf_exp_male_boot),std(zipf_exp_male_boot)));

[zipf_scal_female_boot] = bootstrp(100,@mean,zipf_scal_female);
disp(sprintf('FEMALE scaling: %.3f SE: %.3f',mean(zipf_scal_female_boot),std(zipf_scal_female_boot)));
[zipf_scal_male_boot] = bootstrp(100,@mean,zipf_scal_male);
disp(sprintf('MALE scal: %.3f SE: %.3f',mean(zipf_scal_male_boot),std(zipf_scal_male_boot)));

disp(sprintf('Full-model adjusted-R2 MALE:%.3f FEMALE:%.3f ',mean(zipf_r2_male),mean(zipf_r2_female)));

[p,h]=ranksum(zipf_exp_male,zipf_exp_female);%,'method','exact');
disp(sprintf('Difference MALE vs FEMALE per alpha, effect-size: %.3f pvalue: %.8f',mean(zipf_exp_male)-mean(zipf_exp_female),p));

[p,h]=ranksum(zipf_scal_male,zipf_scal_female);%,'method','exact');
disp(sprintf('Difference MALE vs FEMALE per scaling, effect-size: %.3f pvalue: %.8f',mean(zipf_scal_male)-mean(zipf_scal_female),p));



figure(); hold on
for a=1:authors
author_dictionary=data_zipf{a};
author_dictionary_norm=author_dictionary;
rank_author=tiedrank(author_dictionary*-1);

if(authors_gender(a)==0)
a=plot(log(rank_author), log(author_dictionary_norm),'Color',[male_color, 0.4],'LineWidth',0.001);
hold on;
else
b=plot(log(rank_author), log(author_dictionary_norm),'Color',[female_color, 0.4],'LineWidth',0.001);
hold on;
end
end
if(draw_legend==1);
[~, lgd]=legend([a,b],{'Male','Female'},'Location','northeast','FontSize',legend_fontsize,'FontName','Arial');
lgd_markers=findobj(lgd, 'type', 'Line');
lgd_markers(1).LineWidth=3;
lgd_markers(3).LineWidth=3;
lgd_markers(1).Color=male_color_transp;
lgd_markers(3).Color=female_color_transp;
end
axis square
pbaspect([0.95,0.95,1])

if(draw_titles==1); title('Zipf''s Law'); end
xlabel('log(rank)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('log(occurrences per 1E6 words)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')

xticks([0:2:12])
xticklabels(strsplit(num2str([0:2:12],' %d ')))
yticks([0:2:12])
yticklabels(strsplit(num2str([0:2:12],' %d ')))

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])

xlim([0,12])
ylim([0,12])
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_zipfslaw.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end




figure(); hold on
histogram(zipf_exp_male,'BinMethod','fd','Normalization','probability','FaceColor',male_color,'FaceAlpha',female_transp,'edgecolor','none');
histogram(zipf_exp_female,'BinMethod','fd','Normalization','probability','FaceColor',female_color,'FaceAlpha',male_transp,'edgecolor','none');
if(draw_titles==1); title('Estimation of \alpha exponent');end
xlabel('\alpha exponent, \beta/(x^\alpha) ','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('probability','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
if(draw_legend==1); legend({'Male','Female'},'Location','northeast','FontSize',legend_fontsize,'FontName','Arial'); end
xticks([0.85:0.05:1.20])
xticklabels(strsplit(num2str([0.85:0.05:1.20],' %.2f ')))
xtickangle(45)
yticks([0:0.05:0.15])
yticklabels(strsplit(num2str([0:0.05:0.15],' %.2f ')))

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])
xlim([0.85,1.20])
ylim([0,0.15])
pbaspect([1.5,0.95,1])
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_zipfsalpha.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end



figure(); hold on
histogram(zipf_scal_male,'BinMethod','fd','Normalization','probability','FaceColor',male_color,'FaceAlpha',female_transp,'edgecolor','none');
histogram(zipf_scal_female,'BinMethod','fd','Normalization','probability','FaceColor',female_color,'FaceAlpha',male_transp,'edgecolor','none');
axis square
if(draw_titles==1); title('Estimation of \beta scaling coefficient');end
xlabel('\beta scaling factor, \beta/(x^\alpha) ','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('Probability','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
if(draw_legend==1); legend({'Male','Female'},'Location','northeast','FontSize',legend_fontsize,'FontName','Arial');end
xticks([0.5*1E5:0.2*1E5:2.5*1E5])
xticklabels(strsplit(num2str([0.5*1E5:0.1*1E5:2.5*1E5]./1000,' %dk ')))
xtickangle(45)
yticks([0:0.03:0.12])
yticklabels(strsplit(num2str([0:0.03:0.12],' %.2f ')))
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gca,'TickLength',[0.00, 0.00])
xlim([0.5*1E5,2.5*1E5])
ylim([0,0.12])
pbaspect([1.5,0.95,1])
drawnow


if (save_derivatives==1)
image_filename = strcat('derivatives/plot_basic_stats_zipfsbeta.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end


