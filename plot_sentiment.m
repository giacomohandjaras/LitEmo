clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/borders/');
addpath('additional_functions/export_fig')

save_derivatives=1;
draw_titles=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24+2;

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;
male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;


load('WARRINER/sentiment_analysis_v20220329.mat');
title_labels={'Valence', 'Arousal','Percentage of words used by authors and present in Warriner''s ratings','Number of Warriner''s words used by authors'};

data_final=nan(numel(frequency),4); %1 for valence, 2 for arousal, 3 for the raw frequency, 4 num of used words
for i=1:numel(frequency)
temp=double(frequency{i}); %%%transform occurrences from uint32 to double
data_final(i,3)=sum(temp)./numel(warriner_words{i})*100; %%%evaluate the overall frequency

temp_freq=(temp./numel(warriner_words{i}));
temp_mask=(temp_freq==0);
temp_freq(temp_mask)=[];
temp_freq_rank=tiedrank(temp_freq);
data_final(i,4)=numel(temp_freq_rank)./numel(temp_mask)*100; %%%evaluate how many words in the dictionary were used by the author;

if(authors.final_authors_gender(i)==1) %for female authors
temp_var=(warriner_var_female(temp_mask==0,1).*(log10(temp_freq_rank))); %%%multiply the emotional score by the log10 of the normalized occurrences to penalize frequent words (e.g., like)
data_final(i,1)=sum(temp_var)/sum(log10(temp_freq_rank)); %extract the average score for valence
temp_var=(warriner_var_female(temp_mask==0,2).*(log10(temp_freq_rank)));
data_final(i,2)=sum(temp_var)/sum(log10(temp_freq_rank)); %arousal
else %for male authors
temp_var=(warriner_var_male(temp_mask==0,1).*(log10(temp_freq_rank)));
data_final(i,1)=sum(temp_var)/sum(log10(temp_freq_rank)); %valence
temp_var=(warriner_var_male(temp_mask==0,2).*(log10(temp_freq_rank)));
data_final(i,2)=sum(temp_var)/sum(log10(temp_freq_rank)); %arousal
end

end


save('WARRINER/sentiment_analysis_v20220329.mat','data_final','-append');



%%%% Plot historical trends of valence, arousal, and frequency of words
term=1; plot_ngram_viewer_gender(title_labels(term),'valence scoring',authors.final_authors_pubyear,data_final(:,term),authors.final_authors_gender)
if (save_derivatives==1)
image_filename = strcat('derivatives/plot_sentiment_intime_valence.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end

pause(5)
term=2; plot_ngram_viewer_gender(title_labels(term),'arousal scoring',authors.final_authors_pubyear,data_final(:,term),authors.final_authors_gender)
if (save_derivatives==1)
image_filename = strcat('derivatives/plot_sentiment_intime_arousal.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end

pause(5)
term=3; plot_ngram_viewer_gender(title_labels(term),'percentage (%)',authors.final_authors_pubyear,data_final(:,term),authors.final_authors_gender)
if (save_derivatives==1)
image_filename = strcat('derivatives/plot_sentiment_intime_percentage_authors.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end

pause(5)
term=4; plot_ngram_viewer_gender(title_labels(term),'percentage (%)',authors.final_authors_pubyear,data_final(:,term),authors.final_authors_gender)
if (save_derivatives==1)
image_filename = strcat('derivatives/plot_sentiment_intime_percentage_warriner.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end





load('HDI/LitEmo_HDI_data.mat');

countries=unique(authors.final_authors_country);
year_of_interest=1990;

results_space_number_of_authors=nan(numel(countries),1);
%%%%identify the number of authors of each country 
for c=1:numel(countries)
results_space_number_of_authors(c)=sum(strcmp(authors.final_authors_country,countries{c}) & authors.final_authors_pubyear>=year_of_interest);
end
temp=results_space_number_of_authors;
temp(temp==0)=[];
country_cutoff=prctile(temp,75);
clear temp;

%filter countries with a low number of authors
countries_HDI=countries(results_space_number_of_authors>country_cutoff);

National_HDI_data = HDI_data(HDI_data.Level=='National',:);
National_HDI_data.Country(National_HDI_data.Country=='Chili')='Chile';
National_HDI_data.Country(National_HDI_data.Country=='Trinidad & Tobago')='Trinidad';
National_HDI_data.Country(National_HDI_data.Country=='United Kingdom')='Uk';
National_HDI_data.Country(National_HDI_data.Country=='United States')='Usa';
National_HDI_data.Country(National_HDI_data.Country=='Russian Federation')='Russia';
National_HDI_data.Country(National_HDI_data.Country=='Antigua and Barbuda')='Antigua';
National_HDI_data.Country(National_HDI_data.Country=='Congo Democratic Republic')='Congo';
National_HDI_data.Country(National_HDI_data.Country=='Dominican Republic')='Dominican rep.';
National_HDI_data.Country(National_HDI_data.Country=='Czech Republic')='Czech rep.';
National_HDI_data.Country(National_HDI_data.Country=='Saint Kitts and Nevis')='s. kitts';
National_HDI_data.Country(National_HDI_data.Country=='Saint Lucia')='s. lucia';
National_HDI_data.Country(National_HDI_data.Country=='Saint Vincent and the Grenadines')='s. vincent';
National_HDI_data.Country(National_HDI_data.Country=='United Arab Emirates')='UAE';


for term=1:2

National_HDI_data_newtable = [];
for i = 1:numel(countries_HDI)
    
    if sum(lower(string(National_HDI_data.Country))==lower(countries_HDI{i}))==0        
        fprintf('Missing data for %s\n',countries_HDI{i})
    else
        National_HDI_data_newtable = cat(1,National_HDI_data_newtable,National_HDI_data(lower(string(National_HDI_data.Country))==lower(countries_HDI{i}),:));
    end
end

National_HDI_avg_rank = nanmean(tiedrank(table2array(National_HDI_data_newtable(:,6:end))),2);

countries_score=nan(numel(countries_HDI),1);
for i=1:numel(countries_HDI)
country_mask=find(strcmp(authors.final_authors_country,countries_HDI(i)) & authors.final_authors_pubyear>=year_of_interest);
countries_score(i)=mean(data_final(country_mask,term),1);
end

[r_rank,p_rank]=corr(National_HDI_avg_rank,countries_score,'type','spearman');
coor_ci = @(X,Y)corr(X,Y,'type','spearman');
bootstrap_results=bootci(1000,coor_ci,National_HDI_avg_rank,countries_score);
disp(sprintf('%s: Rho= %.3f, p=%.3f, CI95: %.3f %.3f',title_labels{term},r_rank,p_rank,bootstrap_results));

[p,S] = polyfit(tiedrank(National_HDI_avg_rank),tiedrank(countries_score),1);
X_high=-2:0.1:max(tiedrank(National_HDI_avg_rank)+10);
[y_ext,delta] = polyconf(p,X_high',S);


figure; hold on;
scatter(tiedrank(National_HDI_avg_rank),tiedrank(countries_score),60,'filled','MarkerFaceColor','k','MarkerFaceAlpha',.25,'MarkerEdgecolor','none');
if(p_rank<0.05)
plot(X_high, y_ext,'k--','LineWidth',1);
patch([X_high fliplr(X_high)], [(y_ext'+delta') fliplr((y_ext'-delta'))], 'k','FaceAlpha',0.05,'LineStyle','none');
end

axis square
box off
text(tiedrank(National_HDI_avg_rank)+randi([1 2],numel(National_HDI_avg_rank),1)/3,tiedrank(countries_score)+randi([1 2],numel(countries_score),1)/3, National_HDI_data_newtable.ISO_Code,'FontSize',tick_fontsize-8,'FontName','Arial','Color', [0.3,0.3,0.3])

xlabel('HDI rank','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel([lower(title_labels{term}),' rank'],'Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')

if(draw_titles==1); title(['Correlation between HDI index and ',title_labels{term},', ',sprintf('rho = %.3f; p = %.3f\n',r_rank,p_rank)],'FontSize',label_fontsize,'FontName','Arial', 'FontWeight','normal'); end

xticks(0:10:max(tiedrank(National_HDI_avg_rank))+3);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
yticks(0:10:max(tiedrank(countries_score))+3);
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gcf,'color',[1 1 1])
xlim([0 max(tiedrank(National_HDI_avg_rank))+5]);
ylim([0 max(tiedrank(countries_score))+2]);

drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_sentiment_HDI_',lower(title_labels{term}),'.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end



%%%% Draw worldmaps of valence, arousal
%color_orange=[255,247,188; 254,227,145; 254,196,79; 254,153,41; 236,112,20; 204,76,2; 153,52,4; 102,37,6]./255;
%xlim([0 numel(countries_score)+1]);
%ylim([0 numel(countries_score)+1]);
%axis square
%box off
%text(tiedrank(National_HDI_avg_rank')+1,tiedrank(countries_score')+randi([-2 2],1,numel(countries_score))./5,National_HDI_data_newtable.ISO_Code,'FontSize',12,'FontName','Arial')
%set(gca,'TickDir','out','FontName','Arial','FontSize',16)
%set(gcf,'color',[1 1 1])
%xlabel('HDI Rank');
%ylabel([title_labels{term},' Rank']);
%title(['Correlation between HDI index and ',title_labels{term},', ',sprintf('rho = %.3f; p = %.3f\n',r_rank,p_rank)],'FontSize',12,'FontName','Arial',...
%    'FontWeight','normal')


%countries_freq=tiedrank(countries_score*-1); %to invert colorscale
%color_space=linspace(min(countries_score),max(countries_score),8);
%colors=ones(numel(countries_score),3);
%for i=1:numel(countries_score)
%pos=find(countries_score(i)<=color_space);
%colors(i,:)=color_orange(pos(1),:);
%end

%figure();
%borders('countries','k')
%axis tight
%axis off
%for i=1:numel(countries_HDI)
%borders(countries_HDI{i},'facecolor',colors(i,:))
%end
%title(title_labels{term})

end





%%%% Plot scatters of valence, arousal  across authors

for term=1:2
[p,h]=ranksum(data_final(authors.final_authors_gender==0,term),data_final(authors.final_authors_gender==1,term));
disp(sprintf('%s: difference %.2f, p=%.8f ',title_labels{term},(mean(data_final(authors.final_authors_gender==0,term)))-(mean(data_final(authors.final_authors_gender==1,term))),p));
end


terms=[1,2];
for term=1:size(terms,1)

disp(sprintf('\n\nAnalyzing relationship between %s vs %s',title_labels{terms(term,1)},title_labels{terms(term,2)}));

X=cat(2,authors.final_authors_gender,data_final(:,terms(term,1)));
y=data_final(:,terms(term,2));
LM=fitlm(X,y,[title_labels{terms(term,2)},' ~ gender * ', title_labels{terms(term,1)}],'VarNames' ,{'gender',title_labels{terms(term,1)},title_labels{terms(term,2)}},'Categorical',1);
LM

x_males=[min(data_final(authors.final_authors_gender==0,terms(term,1)))-0.05:0.01:max(data_final(authors.final_authors_gender==0,terms(term,1)))+0.05];
predicted_y_males=LM.Coefficients.Estimate(1)+(zeros(1,numel(x_males)))*LM.Coefficients.Estimate(2)+(x_males).*(LM.Coefficients.Estimate(3))+(zeros(1,numel(x_males)).*x_males)*LM.Coefficients.Estimate(4);

x_females=[min(data_final(authors.final_authors_gender==1,terms(term,1)))-0.05:0.01:max(data_final(authors.final_authors_gender==1,terms(term,1)))+0.05];
predicted_y_females=LM.Coefficients.Estimate(1)+(ones(1,numel(x_females)))*LM.Coefficients.Estimate(2)+(x_females).*(LM.Coefficients.Estimate(3))+(ones(1,numel(x_females)).*x_females)*LM.Coefficients.Estimate(4);

figure(); hold on;

scatter(data_final(authors.final_authors_gender==0,terms(term,1)),data_final(authors.final_authors_gender==0,terms(term,2)),40,'filled','MarkerFaceColor',male_color,'MarkerFaceAlpha',male_transp,'MarkerEdgecolor','none');
plot(x_males,predicted_y_males,'Color',male_color,'LineStyle','--','LineWidth',1);

scatter(data_final(authors.final_authors_gender==1,terms(term,1)),data_final(authors.final_authors_gender==1,terms(term,2)),40,'filled','MarkerFaceColor',female_color,'MarkerFaceAlpha',female_transp,'MarkerEdgecolor','none');
plot(x_females,predicted_y_females,'Color',female_color,'LineStyle','--','LineWidth',1);

axis square
box off

if(draw_titles==1);  title([title_labels{terms(term,1)}, ' vs ', title_labels{terms(term,2)} ,' across authors' ]); end

xlabel(lower(title_labels{terms(term,1)}),'Fontsize',label_fontsize-2,'FontName','Arial','Fontweight','bold')
ylabel(lower(title_labels{terms(term,2)}),'Fontsize',label_fontsize-2,'FontName','Arial','Fontweight','bold')

ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize-2)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize-2)
set(gcf,'color',[1 1 1])


xlim([min(data_final(:,terms(term,1)))-0.1, max(data_final(:,terms(term,1)))+0.1])
ylim([min(data_final(:,terms(term,2)))-0.1, max(data_final(:,terms(term,2)))+0.1])

%legend({'Male authors','Male estimate','Female authors','Female estimate' },'Location','best','FontSize',12)
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_sentiment_',lower(title_labels{terms(term,1)}),'_vs_',lower(title_labels{terms(term,2)}),'.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end

pause(5)


end




