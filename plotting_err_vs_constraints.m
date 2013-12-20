
function plotting_err_vs_constraints(no_sizes, no_algos, no_sparsities, algos_cell, constraints_xaxis, dimvalue_descrip, choice_algos, l, error_name, model_name, prefix, colorsmatrix, file_name)
no_constraints = length(constraints_xaxis);

% Third dimension is value and stddev
Value_vs_Size_Matrix = zeros(no_constraints,no_algos,2);

%% Create Mat errors vs. size
    
    % Use a better implementation than forloop!
    % Put all values in a matrix prepare for plotting
    for i = 1:length(algos_cell)
        Value_vs_Size_Matrix(:,i,:) = algos_cell{i}(no_sizes+no_sparsities+1:no_sizes+no_sparsities+no_constraints,l+1,:);
    end
    
    % Declare the file/title name for plot, dependent on matrix and error
    %title_name = sprintf('%s vs. number of constraints for \n %d number of blocks each with \n %d number of variables and \n sparsity %d on Model %s', ...
    %    error_name, plot_noblocks, plot_novars, plot_sparsity(1), model_name);
    
    ylabel_str = error_name; %sprinf('%s of the reconstructed signal', choice_errortypes{l});
    legend_label = ''; 
    
    % You plot the column vectors (error vs. dimensions) and the different plots are for the different
    % algos
    % eval(['error_mat = models{k}.' sprintf(error_types{l})]);
    [sorted_constraints_xaxis, sorted_ind] = sort(constraints_xaxis);
    plotfrommat(sorted_constraints_xaxis, Value_vs_Size_Matrix(sorted_ind,:,:), ...
        choice_algos, legend_label, strcat(prefix, file_name, '-error'), '', ...
        dimvalue_descrip, ylabel_str, colorsmatrix, 1); % with error bars
    plotfrommat(sorted_constraints_xaxis, Value_vs_Size_Matrix(sorted_ind,:,:), ...
        choice_algos, legend_label, strcat(prefix, file_name), '', ...
        dimvalue_descrip, ylabel_str, colorsmatrix, 0); % without error bars
end