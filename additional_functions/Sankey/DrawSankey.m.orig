% Example data 
% data of the left panel in each block
data1{1}=[1 2]; 
data1{2}=[1 1];


% data of the right panel in each block
data2{1}=data1{2};

% data of flows in each block
data{1}=[1 0 ; 0 0];


% x-axis
X=[0 1];

% panel color
barcolors{1}=[1 0 0; 0 1 1];
barcolors{2}=[1 0 1; 0 1 0; 1 1 0];
barcolors{3}=[1 .6 0; .6 .6 .6; 0 0 1];
barcolors{4}=[.2 1 .2; .6 .6 1];

% flow color
c = [.7 .7 .7];

% Panel width
w = 25; 

colormap(altrwb)

for j=1
    if j>1
        ymax=max(ymax,sankey_yheight(data1{j-1},data2{j-1}));
        y1_category_points=sane_sankey(data1{j}, data2{j}, data{j}, X(j), X(j+1), y1_category_points,ymax,barcolors{j},barcolors{j+1},w,c);
    else
        y1_category_points=[];
        ymax=sankey_yheight(data1{j},data2{j});
        y1_category_points=sane_sankey(data1{j}, data2{j}, data{j}, X(j), X(j+1), y1_category_points,ymax,barcolors{j},barcolors{j+1},w,c);
    end
end
        
