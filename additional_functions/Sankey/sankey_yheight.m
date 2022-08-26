function h = sankey_yheight(data1, data2)

% data1: left ends (vector);
% data2: right ends (vector);

% Find axis dimensions and set them
data1_sum = sum(data1);
data2_sum = sum(data2);

gap1_total = 0.10 * data1_sum;
gap2_total = 0.10 * data2_sum;
gap1 = gap1_total/(length(data1)-1);
gap2 = gap2_total/(length(data2)-1);

y1_height = data1_sum + gap1_total;
y2_height = data2_sum + gap2_total;

h=max(y1_height,y2_height);
end
