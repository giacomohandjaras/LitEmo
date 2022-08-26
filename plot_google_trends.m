clear all
close all

SANETOOLBOX='../../CORPORA/SaneNLP_toolbox';
addpath(SANETOOLBOX);
addpath('additional_functions')
addpath('additional_functions/export_fig')

save_derivatives=1;
draw_titles=0;
draw_legend=1;
label_fontsize=22-2;
tick_fontsize=18-2;
legend_fontsize=18;
male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;
male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;


load('ALL_TERMS/all_terms_010_10000perm_light_v20220112.mat','dictionary_corrected','dictionary','covariates','data_final','data_final_corrected');
GOOGLE=load('GOOGLE/google_fiction2020_v20220219_intime.mat');

dictionary=dictionary_corrected;
data_final=data_final_corrected;

%%%%%%%%%%%%%%%%%%%%
%%%% Fix bigrams
%%%%%%%%%%%%%%%%%%%%
customBigrams=SNLP_loadWords([SANETOOLBOX,'/bigrams_eng.txt']);
for express=1:size(customBigrams,1)
bigram_to_search=strtrim(customBigrams(express,2));
bigram_to_replace=regexprep(strtrim(customBigrams(express,1)),' ','-');
pos=find(strcmp(dictionary,bigram_to_search));
if numel(pos)>0
dictionary(pos)=bigram_to_replace;
end
end


%%%%% first of all, let's reconstruct the google data dor the current dictionary 
GOOGLE_DATA=nan(numel(dictionary),numel(GOOGLE.timeline));

tic
for w=1:numel(dictionary)
if(mod(w,100)==0); toc; disp(sprintf('Word %d/%d',w,numel(dictionary))); tic; end
word=dictionary{w};
%disp(sprintf('Word %s',word));
term=find(strcmp(GOOGLE.dictionary_final,word));
if (~isempty(term))
data_google=zeros(numel(GOOGLE.timeline),1);
for j=1:numel(GOOGLE.time_steps)-1
occurrences_temp_all=GOOGLE.occurrences_final{j};
mask_temp=(GOOGLE.timeline>=GOOGLE.time_steps(j) & GOOGLE.timeline<GOOGLE.time_steps(j+1)); 
data_google(find(mask_temp))=occurrences_temp_all(term,:);
clear occurrences_temp_all mask_temp
end
data_google=(data_google./GOOGLE.occurrences_intime).*100;
data_google(end)=data_google(end-1); %%% "fix" 2020 issues of Google Books
GOOGLE_DATA(w,:)=data_google;
end
end


clear j data_google term bigram_to_replace bigram_to_search express w pos word GOOGLE.occurrences_final

rng(16576);

results_beta=nan(numel(dictionary),4);
tic
for w=1:numel(dictionary)

if(mod(w,25)==0); toc; mask=mean(results_beta,2); temp_results=results_beta(~isnan(mask),:); disp(sprintf('Word %d/%d, corr AllvsG %.3f, corr MvsG %.3f, corr FvsG %.3f',w,numel(dictionary),corr(temp_results(:,1),temp_results(:,4)),corr(temp_results(:,2),temp_results(:,4)),corr(temp_results(:,3),temp_results(:,4)))); tic; end

if (~isnan(sum(GOOGLE_DATA(w,:))))

[results_time_raw,results_time,results_time_up,results_time_down,temporal_windows]=getdata_ngram_viewer(data_final(:,w),covariates.final_authors_pubyear);
[results_time_raw_female,results_time_female,results_time_up_female,results_time_down_female,temporal_windows_female]=getdata_ngram_viewer(data_final(covariates.final_authors_gender==1,w),covariates.final_authors_pubyear(covariates.final_authors_gender==1));

%%%%downsampling male authors to match the same number of the females
temp_data_male=data_final(covariates.final_authors_gender==0,w);
temp_data_male_pubyear=covariates.final_authors_pubyear(covariates.final_authors_gender==0);
random_order=randperm(sum(covariates.final_authors_gender==0));
temp_data_male=temp_data_male(random_order);
temp_data_male=temp_data_male(1:sum(covariates.final_authors_gender==1));
temp_data_male_pubyear=temp_data_male_pubyear(random_order);
temp_data_male_pubyear=temp_data_male_pubyear(1:sum(covariates.final_authors_gender==1));

[results_time_raw_male,results_time_male,results_time_up_male,results_time_down_male,temporal_windows_male]=getdata_ngram_viewer(temp_data_male,temp_data_male_pubyear);
[results_time_google_raw,results_time_google]=getdata_ngram_viewer_google(GOOGLE_DATA(w,:),GOOGLE.timeline,temporal_windows);

%%%scaling to max: it's a good way to make the beta comparable across words with different frequencies
results_time_raw=(results_time_raw)./max(results_time_raw);
results_time_raw_male=(results_time_raw_male)./max(results_time_raw_male);
results_time_raw_female=(results_time_raw_female)./max(results_time_raw_female);
results_time_google_raw=(results_time_google_raw)./max(results_time_google_raw);

B=cat(2,ones(numel(results_time_raw),1),[1:numel(results_time_raw)]')\results_time_raw;
B_male=cat(2,ones(numel(results_time_raw_male),1),[1:numel(results_time_raw_male)]')\results_time_raw_male;
B_female=cat(2,ones(numel(results_time_raw_female),1),[1:numel(results_time_raw_female)]')\results_time_raw_female;

B_google=cat(2,ones(numel(results_time_google_raw),1),[1:numel(results_time_google_raw)]')\results_time_google_raw;

results_beta(w,1)=B(2);
results_beta(w,2)=B_male(2);
results_beta(w,3)=B_female(2);
results_beta(w,4)=B_google(2);

end
end
toc


clear mask temp_results w B B_male B_female B_google results_time_raw results_time results_time_up results_time_down temporal_windows results_time_raw_male results_time_male results_time_up_male results_time_down_male temporal_windows_male results_time_raw_female results_time_female results_time_up_female results_time_down_female temporal_windows_female results_time_google_raw results_time_google

mask=mean(results_beta,2); 
temp_results=results_beta(~isnan(mask),:); 
temp_diff=abs((temp_results(:,1)-temp_results(:,4)));
terms_to_plot=zeros(numel(temp_diff),1);
terms_to_plot(temp_diff>prctile(temp_diff,95))=1;
temp_terms=dictionary(~isnan(mask));

[rho,p]=corr(temp_results(:,1),temp_results(:,4),'type','spearman');
scorr = @(a,b)(corr(a,b,'type','Spearman'));
bootstat = bootstrp(1000,scorr,temp_results(:,1),temp_results(:,4));
disp(sprintf('Correlation between trends in our corpus and Google Fiction 2020: %.3f, CI95: %.3f %.3f, p=%.8f ',rho,prctile(bootstat,2.5),prctile(bootstat,97.5),p));


%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% trend similarities
%%%%%%%%%%%%%%%%%%%%%%%%%
figure(); hold on
line([0,0],[-0.03,0.03],'linewidth',0.1,'linestyle','--','color','k')
line([-0.03,0.03],[0,0],'linewidth',0.1,'linestyle','--','color','k')
line([-0.03,0.03],[-0.03,0.03],'linewidth',0.1,'linestyle','--','color','k')
scatter((temp_results(:,1)),(temp_results(:,4)),40, [0.2,0.2,0.2], 'filled','MarkerFaceAlpha',0.5,'MarkerEdgecolor','none');
hs=lsline;
hs(1).Color='k';
hs(1).LineWidth=2;
text(temp_results(terms_to_plot>0,1)+0.00001,temp_results(terms_to_plot>0,4)+0.00001,temp_terms(terms_to_plot>0),'FontSize',9,'Color','k');
xlim([-0.03,0.03])
ylim([-0.03,0.03])
axis square
xlabel('Linear trends in our corpus (norm \beta)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
ylabel('Linear trends in Google (norm \beta)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
if(draw_titles==1); title('Linear trends estimated in our corpus and Google Fiction 2020'); end
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_google_trends.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end
pause(1);



%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% trend similarities for each sex
%%%%%%%%%%%%%%%%%%%%%%%%%
temp_diff=abs((temp_results(:,3)-temp_results(:,4)));
terms_to_plot=zeros(numel(temp_diff),1);
terms_to_plot(temp_diff>prctile(temp_diff,95))=1;
temp_terms=dictionary(~isnan(mask));
figure(); hold on
line([0,0],[-0.03,0.03],'linewidth',0.1,'linestyle','--','color','k')
line([-0.03,0.03],[0,0],'linewidth',0.1,'linestyle','--','color','k')
line([-0.03,0.03],[-0.03,0.03],'linewidth',0.1,'linestyle','--','color','k')
scatter((temp_results(:,1)),(temp_results(:,4)),40, [0.2,0.2,0.2], 'filled','MarkerFaceAlpha',0,'MarkerEdgecolor','none');
scatter((temp_results(:,2)),(temp_results(:,4)),40, 'filled','MarkerFaceColor',male_color,'MarkerFaceAlpha',male_transp,'MarkerEdgecolor','none');
scatter((temp_results(:,3)),(temp_results(:,4)),40, 'filled','MarkerFaceColor',female_color,'MarkerFaceAlpha',female_transp,'MarkerEdgecolor','none');
hs=lsline;
hs(3).Color='k';
hs(3).LineWidth=2;
hs(2).Color=male_color;
hs(2).LineWidth=2;
hs(1).Color=female_color;
hs(1).LineWidth=2;
text(temp_results(terms_to_plot>0,3)+0.00001,temp_results(terms_to_plot>0,4)+0.00001,temp_terms(terms_to_plot>0),'FontSize',9);
xlim([-0.03,0.03])
ylim([-0.03,0.03])
axis square
xlabel('Linear trends in our corpus for Males and Females (norm \beta)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
ylabel('Linear trends in Google (norm \beta)','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
if(draw_titles==1); title('Linear trends estimated in our corpus in each sex and Google Fiction 2020'); end
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)
drawnow

if (save_derivatives==1)
image_filename = strcat('derivatives/plot_google_trends_by_sex.png');
export_fig(image_filename,'-m6','-nocrop', '-transparent','-silent');
end
pause(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rho_male,p]=corr(temp_results(:,2),temp_results(:,4),'type','spearman');
scorr = @(a,b)(corr(a,b,'type','Spearman'));
bootstat = bootstrp(1000,scorr,temp_results(:,2),temp_results(:,4));
disp(sprintf('Correlation between MALE trends in our corpus and Google Fiction 2020: %.3f, CI95: %.3f %.3f, p=%.8f ',rho_male,prctile(bootstat,2.5),prctile(bootstat,97.5),p));

[rho_female,p]=corr(temp_results(:,3),temp_results(:,4),'type','spearman');
scorr = @(a,b)(corr(a,b,'type','Spearman'));
bootstat = bootstrp(1000,scorr,temp_results(:,3),temp_results(:,4));
disp(sprintf('Correlation between FEMALE trends in our corpus and Google Fiction 2020: %.3f, CI95: %.3f %.3f, p=%.8f ',rho_female,prctile(bootstat,2.5),prctile(bootstat,97.5),p));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Assessment of the difference
rho_diff=rho_male-rho_female;
rng(16576);

permutations=10000;
rho_null=nan(permutations,2);
for perm=1:permutations
temp_mask=randn(numel(temp_results(:,4)),1);
temp_mask=temp_mask>0;
temp_data=nan(numel(temp_mask),1);
temp_data(temp_mask==0)=temp_results(temp_mask==0,2);
temp_data(temp_mask==1)=temp_results(temp_mask==1,3);
[rho_temp]=corr(temp_data,temp_results(:,4),'type','spearman');
rho_null(perm,1)=rho_temp;
temp_data=nan(numel(temp_mask),1);
temp_data(temp_mask==0)=temp_results(temp_mask==0,3);
temp_data(temp_mask==1)=temp_results(temp_mask==1,2);
[rho_temp]=corr(temp_data,temp_results(:,4),'type','spearman');
rho_null(perm,2)=rho_temp;
end

rho_null_effect=rho_null(:,1)-rho_null(:,2);

if(rho_diff>0)
[pvalue_perm,critical_value_at_p]=pareto_right_tail(rho_null_effect,rho_diff,0.05);
disp(sprintf('Sex effect in Google Fiction 2020: rho %.3f, p=%.8f ',rho_diff,pvalue_perm*2));
figure();
histogram(rho_null_effect,'FaceColor','k','Normalization','probability'); hold on
line([rho_diff,rho_diff],[0,0.08],'linewidth',1,'linestyle','--','color','k');
xlim([-0.10,0.13]);
ylim([0,0.1]);
title('Null distribution of sex differences in trends');
xlabel('Male trends minus female trends as compared to Google Fiction 2020 (rho)');
ylabel('probability');
hold off
end



