load('colorsmatrix.mat')
% Generating random linear functions to test plotmat

no_nodes = [1,2,3,4,5];
no_lines = 6;
error_mat = zeros(5,no_lines); % 6 lines

% Generate the 'data'
for i = 1:no_lines
    error_mat(:,i) = i+no_nodes;
end

choice_algos = {'a','b','c','d','e','f'};
file_name = sprintf('%s.fig','dealing');
title_name = 'Some title';
ylabel_str = 'Random';

fig = plotfrommat(no_nodes, error_mat, choice_algos, 'Tested Algorithms', file_name, ...
            title_name, 'Number of nodes', ylabel_str, colorsmatrix);    