%plots matrix with 1st column  =x-axis, several following columns=y-axis

function fig = plotfrommat(x_axis,matrix,legend_str,legend_label,file_name,title_name,xlabel_str, ylabel_str, colorsmatrix, draw_errorbars)
close all

parameters;

% legend_str = strrep(legend_str,char(95),' ');
% legend_str = strrep(legend_str,'cvx','');

% Get the right legend
for i = 1:length(legend_str)
    legend_str{i} = algo_names(legend_str{i});
end

% Don't need title and legend label
title_name = ''; %strrep(title_name,char(95),' ');

pltype_str_arr = ['- ';'--';'-.';': '];  
no_pltypes = length(pltype_str_arr);
%initialising
mat_size = size(matrix);
n_plots = mat_size(2);
%rows = ceil(n_plots/3);
fig = figure('name',title_name,'numbertitle','off');
if draw_errorbars    
    yy = errorbar(x_axis, matrix(:,1,1), matrix(:,1,2), 'linewidth', 1, 'Color', [colorsmatrix(1,1) colorsmatrix(1,2) colorsmatrix(1,3)]); %create plot handle
else
    yy = plot(x_axis, matrix(:,1,1), 'linewidth', 1, 'Color', [colorsmatrix(1,1) colorsmatrix(1,2) colorsmatrix(1,3)]); %create plot handle
end
grid on;

xlabel(xlabel_str,'fontsize',16);
ylabel(ylabel_str,'fontsize',16);
% Change title font
title(title_name);
title_hdl = get(gca,'title');
set(title_hdl, 'FontSize', 16);

% % %Set axes limits
axes_hdl = get(yy,'Parent'); %create axes handle
%set(axes,'FontSize',16);

% Set the range automatically somehow
% Get the lowest value of all matrix
if draw_errorbars
    range_min = min(min(matrix(:,:,1) - matrix(:,:,2)));
    range_max = max(max(matrix(:,:,1) + matrix(:,:,2)));
else
    range_min = min(min(matrix(:,:,1)));
    range_max = max(max(matrix(:,:,1)));
end
domain_min = min(x_axis);
domain_max = max(x_axis);

% Add some margins to the domain and the range so that 
% the extreme points of the graph don't touch the borders
range_margin = (range_max - range_min) * .05;
domain_margin = (domain_max - domain_min) * .05;
if range_margin == 0
    range_margin = 1;
end
if domain_margin == 0
    domain_margin = 1;
end
range_max = range_max + range_margin;
range_min = range_min - range_margin;
domain_max = domain_max + domain_margin;
domain_min = domain_min - domain_margin;

set(axes_hdl,'xlim',[domain_min domain_max],'ylim',[range_min range_max],'fontsize',16);
hold on;
if n_plots > 1
    for n=2:n_plots
        linestr = sprintf('%s%s',pltype_str_arr(mod(n,no_pltypes)+1,1),pltype_str_arr(mod(n,no_pltypes)+1,2));
        if draw_errorbars
            errorbar(x_axis, matrix(:,n,1), matrix(:,n,2), 'linewidth', 2, 'Color', [colorsmatrix(mod(n,17)+1,1) colorsmatrix(mod(n,17)+1,2) colorsmatrix(mod(n,17)+1,3)], 'linestyle', linestr); %create plot handle
        else
            plot(x_axis, matrix(:,n,1), 'linewidth', 2, 'Color', [colorsmatrix(mod(n,17)+1,1) colorsmatrix(mod(n,17)+1,2) colorsmatrix(mod(n,17)+1,3)], 'linestyle', linestr); %create plot handle
        end
        grid on;
    end
end

legend_hdl1 = legend(legend_str,'Location','NorthEast'); %num2str(legend_str));
legend_hdl = get(legend_hdl1,'title');
%legend(legend_hdl,'Location','NorthEastOutside');
set(legend_hdl,'string',legend_label);
saveas(fig,strcat(file_name, '.fig'));
print(fig, '-dpdf', strcat(file_name, '.pdf'))
end

