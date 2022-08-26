function plot_ngram_viewer_gender(label_title,label_y,years,data,sex)

draw_titles=1;
draw_legend=1;
label_fontsize=22-2;
tick_fontsize=18-2;
legend_fontsize=16;

male_color=[227,26,28]./255;
female_color=[51,160,44]./255;
male_transp=0.66;
female_transp=0.66;
male_color_transp=[237,104,105]./255; %%when transparency is not supported....
female_color_transp=[121,192,116]./255;

perctile_window=10;
smoothing_filter=0.8;
steps=perctile_window*0.20; %%%the overlap
bootstraps=1000;

temporal_windows=[];
rank_range=[0:steps:100-perctile_window];
for i=1:numel(rank_range)
temporal_windows(1,i)=prctile(years,rank_range(i));
temporal_windows(2,i)=prctile(years,rank_range(i)+perctile_window);
end

temporal_windows(1,1)=min(years)-eps;
temporal_windows(2,end)=max(years)+eps;

data_selected=data;

data_selected_male=data_selected(sex==0);
data_selected_female=data_selected(sex==1);

data_time_male=years(sex==0);
data_time_female=years(sex==1);

time_male=nan(size(temporal_windows,2),1);
time_male_up=nan(size(temporal_windows,2),1);
time_male_down=nan(size(temporal_windows,2),1);

time_female=nan(size(temporal_windows,2),1);
time_female_up=nan(size(temporal_windows,2),1);
time_female_down=nan(size(temporal_windows,2),1);

for i=1:size(temporal_windows,2)
temporal_mask=data_time_male>=temporal_windows(1,i) & data_time_male<=temporal_windows(2,i);
temp_male=data_selected_male(temporal_mask);
time_male(i)=nanmean(temp_male);

bootstraps_mean=bootstrp(bootstraps,@nanmean,temp_male);
time_male_up(i)=prctile(bootstraps_mean,97.5);
time_male_down(i)=prctile(bootstraps_mean,2.5);

temporal_mask=data_time_female>=temporal_windows(1,i) & data_time_female<=temporal_windows(2,i);
temp_female=data_selected_female(temporal_mask);
time_female(i)=nanmean(temp_female);

bootstraps_mean=bootstrp(bootstraps,@nanmean,temp_female);
time_female_up(i)=prctile(bootstraps_mean,97.5);
time_female_down(i)=prctile(bootstraps_mean,2.5);
end

f_male_raw=time_male;
f_female_raw=time_female;

if (smoothing_filter>0)
temp_f_male_up=fit([1:numel(time_male_up)]',time_male_up,'smoothingspline','SmoothingParam',smoothing_filter);
f_male_up=temp_f_male_up([1:numel(time_male_up)]');
temp_f_male_down=fit([1:numel(time_male_down)]',time_male_down,'smoothingspline','SmoothingParam',smoothing_filter);
f_male_down=temp_f_male_down([1:numel(time_male_down)]');
temp_f_male=fit([1:numel(time_male)]',time_male,'smoothingspline','SmoothingParam',smoothing_filter);
f_male=temp_f_male([1:numel(time_male)]');

temp_f_female_up=fit([1:numel(time_female_up)]',time_female_up,'smoothingspline','SmoothingParam',smoothing_filter);
f_female_up=temp_f_female_up([1:numel(time_female_up)]');
temp_f_female_down=fit([1:numel(time_female_down)]',time_female_down,'smoothingspline','SmoothingParam',smoothing_filter);
f_female_down=temp_f_female_down([1:numel(time_female_down)]');
temp_f_female=fit([1:numel(time_female)]',time_female,'smoothingspline','SmoothingParam',smoothing_filter);
f_female=temp_f_female([1:numel(time_female)]');

else
f_male=time_male;
f_male_up=time_male_up;
f_male_down=time_male_down;
f_female=time_female;
f_female_up=time_female_up;
f_female_down=time_female_down;
end



temporal_windows=mean(temporal_windows,1);
labels_x=round(temporal_windows);

fig=figure(); hold on;

temporal_windows_female=1:numel(temporal_windows);
temporal_windows_female_mask=isnan(f_female_up);
temporal_windows_female(temporal_windows_female_mask)=[];
f_female_down(temporal_windows_female_mask)=[];
f_female_up(temporal_windows_female_mask)=[];
f_female(temporal_windows_female_mask)=[];
f_female_raw(temporal_windows_female_mask)=[];

temporal_windows_male=1:numel(temporal_windows);
temporal_windows_male_mask=isnan(f_male_up);
temporal_windows_male(temporal_windows_male_mask)=[];
f_male_down(temporal_windows_male_mask)=[];
f_male_up(temporal_windows_male_mask)=[];
f_male(temporal_windows_male_mask)=[];
f_male_raw(temporal_windows_male_mask)=[];

temporal_windows_fill = [temporal_windows_male, fliplr(temporal_windows_male)];
inBetween = [f_male_down; flipud(f_male_up)];
fill(temporal_windows_fill, inBetween, male_color,'FaceAlpha',0.4,'LineStyle','none');
plot(temporal_windows_male,f_male,'Color',male_color,'LineWidth',1.5,'LineStyle','-');
a=scatter(1:numel(temporal_windows),f_male_raw,80,'filled','MarkerFaceColor',male_color,'MarkerFaceAlpha',male_transp,'MarkerEdgecolor','none');
%plot(1:numel(temporal_windows),f_male_up,'k--','LineWidth',1)
%plot(1:numel(temporal_windows),f_male_down,'k--','LineWidth',1)

temporal_windows_fill = [temporal_windows_female, fliplr(temporal_windows_female)];
inBetween = [f_female_down; flipud(f_female_up)];
fill(temporal_windows_fill, inBetween, female_color,'FaceAlpha',0.4,'LineStyle','none');
plot(temporal_windows_female,f_female,'Color',female_color,'LineWidth',1.5,'LineStyle','-');
b=scatter(1:numel(temporal_windows),f_female_raw,80,'filled','MarkerFaceColor',female_color,'MarkerFaceAlpha',female_transp,'MarkerEdgecolor','none');
%plot(temporal_windows_female,f_female_up,'k--')
%plot(temporal_windows_female,f_female_down,'k--')

ylabel(label_y,'Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');
xlabel('historical period','Fontsize',label_fontsize,'FontName','Arial','Fontweight','bold');

xticks(1:5:numel(temporal_windows));
xticklabels(labels_x(1:5:numel(temporal_windows)));
xtickangle(45);
ticks = get(gca,'XTickLabel');
set(gca,'XTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)

ax = fig.Children;
ax.YAxis.Exponent = 0;


if max(f_female_up(:)>0.01)
ytickformat('%.4f');
end

if max(f_female_up(:)>0.1)
ytickformat('%.3f');
end

if max(f_female_up(:)>1)
ytickformat('%.2f');
end

limit_y_inf=min(cat(1,f_male_down(:),f_female_down(:)));
limit_y_sup=max(cat(1,f_male_up(:),f_female_up(:)));
if(limit_y_inf<0); limit_y_inf=0; end
ax.YLim = [limit_y_inf,limit_y_sup+eps];
%ylim([4,4.4])

ticks = get(gca,'YTickLabel');
set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',tick_fontsize)

xlim([0,numel(temporal_windows)+1])

if(draw_legend==1); 
%legend('CI95 Male','Male interp','Male raw','CI95 Female','Female interp','Female raw','Location','best'); end
[~, lgd]=legend([a,b],{'Male','Female'},'Location','northwest','FontSize',legend_fontsize,'FontName','Arial');
lgd_markers=findobj(lgd, 'type', 'Patch');
lgd_markers(1).MarkerSize=16;
lgd_markers(2).MarkerSize=16;
lgd_markers(1).MarkerFaceColor=male_color_transp;
lgd_markers(2).MarkerFaceColor=female_color_transp;
end

if(draw_titles==1); title(label_title,'FontSize',legend_fontsize+4,'FontName','Arial'); end

set(gcf,'color',[1 1 1])
box off
pbaspect([1.25,0.85,1])
drawnow

end
