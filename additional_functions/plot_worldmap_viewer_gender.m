function plot_worldmap_viewer_gender(label_title,data,sex,countries)
addpath('additional_functions/borders/');
addpath('additional_functions/Colormaps/');

draw_titles=1;
draw_legend=1;
label_fontsize=22-2;
tick_fontsize=18-2;
legend_fontsize=20-2;

data_selected=data;
country_unique=unique(countries);

country_effect=zeros(numel(country_unique),1);
country_p=nan(numel(country_unique),1);

for c=1:numel(country_unique)
temp_male=data_selected(sex==0 & strcmp(countries, country_unique(c)));
temp_female=data_selected(sex==1 & strcmp(countries, country_unique(c)));

temp_male(isnan(temp_male))=[];
temp_female(isnan(temp_female))=[];

if (numel(temp_male)>0 & numel(temp_female)>0)
country_effect(c)=mean(temp_male)-mean(temp_female);
d = computeCohen_d(temp_male, temp_female, 'independent'); 
%[p,h]=ranksum(temp_male,temp_female);
country_p(c)=d;
end

end

country_p(isinf(country_p))=nan;

colors=brewermap([],"RdYlGn");

colors_male=flipud(colors(1:round(size(colors,1)/2)-25,:)); %%%remove a bit of the central part
colors_female=(colors(round(size(colors,1)/2)+25:end,:));

num_of_colors_male=size(colors_male,1);
num_of_colors_female=size(colors_female,1);

colors_scale_male=linspace(0,1.20,num_of_colors_male); %%%scaling  of cohen's d from 0 to 1.20
colors_scale_female=linspace(0,1.20,num_of_colors_female); %%%scaling  of cohen's d from 0 to 1.20


figure();  hold on;
borders('countries','Color',[0.7,0.7,0.7]); 
axis off
for i=1:numel(country_unique)

%disp(sprintf('%s: %.2f',country_unique{i},country_p(i)));

if(country_p(i)>0)
pos=abs(colors_scale_male-country_p(i));
[~,pos]=min(pos);
borders(country_unique{i},'facecolor',colors_male(pos,:))
end

if(country_p(i)<=0)
pos=abs(colors_scale_female-abs(country_p(i)));
[~,pos]=min(pos);
borders(country_unique{i},'facecolor',colors_female(pos,:))
end

if(isnan(country_p(i)))
borders(country_unique{i},'facecolor',[0.80,0.80,0.80]);
end

end

if(draw_titles==1);  title(label_title,'FontSize',legend_fontsize-4,'FontName','Arial'); end
pbaspect([1.7,1,1])
drawnow


end

