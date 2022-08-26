clear all
clc

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions/');
addpath('additional_functions/export_fig')

load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat', 'covariates', 'dictionary', 'data_final');

save_derivatives=1;
draw_titles=0;
label_fontsize=22+2;
tick_fontsize=18+2;
legend_fontsize=24+2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

year_of_interest=1990;
countries=unique(covariates.final_authors_country);
results_space_cohen=nan(numel(dictionary),numel(countries));
results_space_cohen_noabs=nan(numel(dictionary),numel(countries));


for term=1:numel(dictionary)
selected_word=dictionary(term);
word=find(strcmp(dictionary,selected_word));

if (mod(term,100)==0)
fprintf('Current word %s, %d out of %d\n',selected_word, term,numel(dictionary));
end

data_selected=data_final(:,word);

for c=1:numel(countries)
%disp(sprintf('Processing country %s ',countries{c}));
data_selected_male=data_selected(covariates.final_authors_gender==0 & strcmp(covariates.final_authors_country,countries{c}) & covariates.final_authors_pubyear>=year_of_interest);
data_selected_female=data_selected(covariates.final_authors_gender==1 & strcmp(covariates.final_authors_country,countries{c}) & covariates.final_authors_pubyear>=year_of_interest);
if (numel(data_selected_male)>0); data_selected_male(isnan(data_selected_male))=[]; end
if (numel(data_selected_female)>0); data_selected_female(isnan(data_selected_female))=[]; end
d = computeCohen_d(data_selected_male, data_selected_female, 'independent'); 
results_space_cohen(term,c)=abs(d);
results_space_cohen_noabs(term,c)=(d);
end
end

results_space_cohen(isinf(results_space_cohen))=nan;
test_map=nanmean(results_space_cohen);
disp(sprintf('Countries with an effect since year %d: %d out of %d ',year_of_interest,sum(~isnan(test_map)),numel(test_map)));

plot_worldmap_viewer(test_map,countries)
if(draw_titles==1);  title(['Worldmap of gender-related Cohen''s d starting from ',num2str(year_of_interest,'%d')]);end

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_HDI_worldmap.png');
export_fig(image_filename,'-m10','-nocrop', '-transparent','-silent');
end



%%%%Now correlate cohen's d with HDI

load('HDI/LitEmo_HDI_data.mat');

countries_1990 = countries(isnan(test_map)==0);
cohen_1990 = test_map(isnan(test_map)==0);

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

National_HDI_data_newtable = [];
for i = 1:numel(countries_1990)
    
    if sum(lower(string(National_HDI_data.Country))==lower(countries_1990{i}))==0
        
        fprintf('Missing data for %s\n',countries_1990{i})
        
    else
        National_HDI_data_newtable = cat(1,National_HDI_data_newtable,National_HDI_data(lower(string(National_HDI_data.Country))==lower(countries_1990{i}),:));
    end
end



National_HDI_avg_rank = nanmean(tiedrank(table2array(National_HDI_data_newtable(:,6:end))),2);
cohen_1990_rank=tiedrank(cohen_1990');

rng(14051983)
[r_rank,p_rank]=corr(National_HDI_avg_rank,cohen_1990_rank,'type','spearman');
coor_ci = @(X,Y)corr(X,Y,'type','spearman');
bootstrap_results=bootci(1000,coor_ci,National_HDI_avg_rank,cohen_1990_rank);
disp(sprintf('Rho: %.3f, p=%.3f, CI95: %.3f %.3f',r_rank,p_rank,bootstrap_results));


[p,S] = polyfit(tiedrank(National_HDI_avg_rank),tiedrank(cohen_1990)',1);
X_high=-2:0.1:max(tiedrank(National_HDI_avg_rank)+10);
[y_ext,delta] = polyconf(p,X_high',S);


figure(); hold on;
scatter(tiedrank(National_HDI_avg_rank),tiedrank(cohen_1990),60,'filled','MarkerFaceColor','k','MarkerFaceAlpha',.25,'MarkerEdgecolor','none');
if(p_rank<0.05)
plot(X_high, y_ext,'k--','LineWidth',1);
patch([X_high fliplr(X_high)], [(y_ext'+delta') fliplr((y_ext'-delta'))], 'k','FaceAlpha',0.05,'LineStyle','none');
end

axis square
box off
text(tiedrank(National_HDI_avg_rank)+randi([1 2],numel(National_HDI_avg_rank),1)/2,tiedrank(cohen_1990)+randi([1 2],1,numel(countries_1990))/2, National_HDI_data_newtable.ISO_Code,'FontSize',tick_fontsize-8,'FontName','Arial','Color', [0.3,0.3,0.3])

xlabel('HDI rank','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')
ylabel('absolute Cohen''s d rank','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold')

if(draw_titles==1); title(['Correlation between HDI index and gender-related Cohen''s d, ',sprintf('rho = %.3f; p = %.3f\n',r_rank,p_rank)],'FontSize',label_fontsize,'FontName','Arial', 'FontWeight','normal'); end

xticks(0:10:max(tiedrank(National_HDI_avg_rank))+3);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
yticks(0:10:max(tiedrank(cohen_1990))+3);
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
set(gcf,'color',[1 1 1])
xlim([0 max(tiedrank(National_HDI_avg_rank))+5]);
ylim([0 max(tiedrank(cohen_1990))+5]);

drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_HDI_sex_country.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end


