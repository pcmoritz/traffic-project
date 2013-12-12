
function plotting_err_vs_constraints(no_sizes, no_algos, no_sparsities, algos_cell, constraints_xaxis, dimvalue_descrip, choice_algos, l, error_name, model_name, prefix, colorsmatrix, plot_noblocks, plot_novars, plot_sparsity)
no_constraints = length(constraints_xaxis);
Value_vs_Size_Matrix = zeros(no_constraints,no_algos);

%% Create Mat errors vs. size
    
    % Use a better implementation than forloop!
    % Put all values in a matrix prepare for plotting
    for i = 1:length(algos_cell)
        mat_cache = algos_cell{i};
        Value_vs_Size_Matrix(:,i) = mat_cache(no_sizes+no_sparsities+1:no_sizes+no_sparsities+no_constraints,l+1);
    end
    
    % Declare the file/title name for plot, dependent on matrix and error
    title_name = sprintf('%s vs. number of constraints for \n %d number of blocks each with \n %d number of variables and \n sparsity %d on Model %s', ...
        error_name, plot_noblocks, plot_novars, plot_sparsity(1), model_name);
    file_name = sprintf('%s_vs_Constraints_Model%s',  ...
        error_name, model_name);
    ylabel_str = error_name; %sprinf('%s of the reconstructed signal', choice_errortypes{l});
    
    % You plot the column vectors (error vs. dimensions) and the different plots are for the different
    % algos
    % eval(['error_mat = models{k}.' sprintf(error_types{l})]);
    [sorted_constraints_xaxis, sorted_ind] = sort(constraints_xaxis);
    plotfrommat(sorted_constraints_xaxis, Value_vs_Size_Matrix(sorted_ind,:), ...
        choice_algos, 'Tested Algorithms', strcat(prefix, file_name), title_name, ...
        dimvalue_descrip, ylabel_str, colorsmatrix);
end