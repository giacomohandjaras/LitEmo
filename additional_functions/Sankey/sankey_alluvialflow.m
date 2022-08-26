function h = sankey_alluvialflow(data1, data2, data, x1, x2,last_category_points,ymax,barcolors1,barcolors2,w,patch_color)

data1_sum = sum(data1);
data2_sum = sum(data2);

gap1_total = 0.25 * data1_sum;
gap2_total = 0.25 * data2_sum;
gap1 = gap1_total/(length(data1)-1);
gap2 = gap2_total/(length(data2)-1);

y1_height = data1_sum + gap1_total;
y2_height = data2_sum + gap2_total;


ymax=max(ymax,max(y1_height,y2_height));

axis ij % origin is top left
axis off
    
hold on
    
% These are the top points for each left category, with gaps added.
if isempty(last_category_points)
    y1_category_points = [max(0,(y2_height-y1_height)/2) cumsum(data1)] + (0:numel(data1)) .* gap1;
    y1_category_points(end) = [];
else 
    y1_category_points=last_category_points;
end

% These are the top points for each right category,
% with gaps added.
y2_0=y1_category_points(1)+(y1_height-y2_height)/2;
y2_category_points = [y2_0 y2_0+cumsum(data2)] + (0:numel(data2)) .* gap2;
y2_category_points(end) = [];
h=y2_category_points;
     
% Draw the patches, an entire left category at a time

right_columns_so_far = y2_category_points(1:end); % Start at the beginning of each right category and stack as we go.
patches_per_left_category = size(data, 2);
for k_left = 1:size(data, 1) % for each row
    
    %%% Controlliamo che ci sia da disegnare qualcosa!
    if sum((data(k_left,:)~=0))>0


    % Calculate the coordinates for all the patches split by the
    % Split the left category
    left_patch_points = [0 cumsum(data(k_left, :))] + y1_category_points(k_left);
    patch_top_lefts = left_patch_points(1:end-1);
    patch_bottom_lefts = left_patch_points(2:end);
    
    % Compute and stack up slice of each right category
    patch_top_rights = right_columns_so_far;
    patch_bottom_rights = patch_top_rights + data(k_left, :);
    right_columns_so_far = patch_bottom_rights;
    
    % Plot the patches
    
    % X coordinates of patch corners
    [bottom_curves_x, bottom_curves_y] = get_curves(x1+0.005, patch_bottom_lefts, x2-0.005, patch_bottom_rights);
    [top_curves_x,    top_curves_y]    = get_curves(x2-0.005, patch_top_rights,   x1+0.005, patch_top_lefts);
    X = [ ...
        repmat([x1; x1], 1, patches_per_left_category); % Top left, bottom left
        bottom_curves_x;
        repmat([x2; x2], 1, patches_per_left_category); % Bottom right, top right
        top_curves_x
        ];
    
    % Y coordinates of patch corners
    Y = [ ...
        patch_top_lefts;
        patch_bottom_lefts;
        bottom_curves_y;
        patch_bottom_rights;
        patch_top_rights;
        top_curves_y
        ];
    
    patch('XData', X, 'YData', Y, 'FaceColor', patch_color, 'FaceAlpha', .4, 'EdgeColor', 'none');


    end % se c'è un elemento
    end % for each row

% plot left category bars

for i=1:numel(y1_category_points)
    y1=[y1_category_points; (y1_category_points + data1)];
    plot(ones(2, 1)*x1, y1(:,i), 'Color', barcolors1(i,:),'LineWidth',w);
end
hold on

% plot right category bars
for i=1:numel(y2_category_points)
    y2=[y2_category_points; (y2_category_points + data2)];
    plot(ones(2, 1)*x2, y2(:,i), 'Color', barcolors2(i,:),'LineWidth',w);
end
    

end % alluvialflow

function [x, y] = get_curves(x1, y1, x2, y2)
% x1, x2: scalar x coordinates of line start, end
% y1, y2: vectors of y coordinates of line start/ends
    Npoints = 15;
    t = linspace(0, pi, Npoints);
    c = (1-cos(t))./2; % Normalized curve
    
    Ncurves = numel(y1);
    y = repmat(y1, Npoints, 1) + repmat(y2 - y1, Npoints,1) .* repmat(c', 1, Ncurves);
    x = repmat(linspace(x1, x2, Npoints)', 1, Ncurves);
end  % get_curve
