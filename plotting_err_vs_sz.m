function plotting_err_vs_sz(no_sizes, no_algos, algos_cell, size_xaxis, dimvalue_descrip, choice_algos, l, error_name, model_name, prefix, colorsmatrix,file_name)

% Third dimension is value and stddev
Value_vs_Size_Matrix = zeros(no_sizes,no_algos,2);

%% Create Mat errors vs. size
    
    % Use a better implementation than forloop!
    % Put all values in a matrix prepare for plotting
    for i = 1:length(algos_cell)
        Value_vs_Size_Matrix(:,i,:) = algos_cell{i}(1:no_sizes,l+1,:);
    end
    
    % Declare the file/title name for plot, dependent on matrix and error
    title_name = sprintf('%s vs. Size on Model %s', ...
        error_name, model_name);
    
    %file_name = sprintf('%s_vs_Size_Model%s',  ...
    %    error_name, model_name);
    ylabel_str = error_name; %sprinf('%s of the reconstructed signal', choice_errortypes{l});
    
    % You plot the column vectors (error vs. dimensions) and the different plots are for the different
    % algos
    % eval(['error_mat = models{k}.' sprintf(error_types{l})]);
    [sorted_size_xaxis, sorted_ind] = sort(size_xaxis);
    plotfrommat(sorted_size_xaxis, Value_vs_Size_Matrix(sorted_ind,:,:), ...
        choice_algos, '', strcat(prefix, file_name), title_name, ...
        dimvalue_descrip, ylabel_str, colorsmatrix, 1); % with error bars
    plotfrommat(sorted_size_xaxis, Value_vs_Size_Matrix(sorted_ind,:,:), ...
        choice_algos, '', strcat(prefix, file_name), title_name, ...
        dimvalue_descrip, ylabel_str, colorsmatrix, 0); % without error bars
end