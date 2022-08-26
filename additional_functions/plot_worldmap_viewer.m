function plot_worldmap_viewer(country_p,countries)
addpath('additional_functions/borders/');
addpath('additional_functions/Colormaps/');
addpath('additional_functions/Colormaps')


country_p=abs(country_p);
country_p(isinf(country_p))=nan;

country_p_mask=isnan(country_p);

country_p(country_p_mask)=[];
countries(country_p_mask)=[];

disp(sprintf('MIN-MAX: %.2f - %.2f',min(country_p),max(country_p)));

colors_to_map=viridis;
%colormap(viridis)
colors=tiedrank(country_p);
colors=round((colors./max(colors))*256);

%for i=1:numel(countries)
%disp(sprintf('Paese %s, effetto %.2f, colore %.2f',countries{i},country_p(i),colors(i)));
%end

figure();
borders('countries','Color',[0.7,0.7,0.7])
axis off
for i=1:numel(country_p)
borders(countries{i},'facecolor',colors_to_map(colors(i),:))
end
pbaspect([1.7,1,1])
drawnow



end



