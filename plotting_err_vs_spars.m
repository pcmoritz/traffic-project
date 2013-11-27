function plotting_err_vs_spars(no_sizes, no_algos, no_sparsities, algos_cell,sparsity_xaxis, choice_algos, l, error_name, model_name, prefix,  colorsmatrix)

Value_vs_Sparsity_Matrix = zeros(no_sparsities,no_algos);
%% Create Mat errors vs. sparsity

    % Put all values in a matrix prepare for plotting
    for i = 1:length(algos_cell)
        mat_cache = algos_cell{i};
        Value_vs_Sparsity_Matrix(:,i) = mat_cache(no_sizes+1:no_sizes+no_sparsities,l+1);
    end
    
    % Declare the file/title name for plot, dependent on matrix and error
    title_name = sprintf('%s vs. Sparsity on Model %s', ...
        error_name, model_name);
    file_name = sprintf('%s_vs_Sparsity_Model%s', ...
        error_name, model_name);
    ylabel_str =  error_name; %sprinf('%s of the reconstructed signal',);
    
    % You plot the column vectors (error vs. sparsity) and the different plots are for the different
    % algos
    [sorted_sparsity_xaxis, sorted_ind] = sort(sparsity_xaxis);
    plotfrommat(sorted_sparsity_xaxis, ...
        Value_vs_Sparsity_Matrix(sorted_ind,:), choice_algos, ...
        'Tested Algorithms', strcat(prefix, file_name), ...
        title_name, 'Sparsity', ylabel_str, colorsmatrix);
end