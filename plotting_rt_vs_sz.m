function plotting_rt_vs_sz(no_sizes, no_algos, algos_cell, size_xaxis_rt, dimvalue_descrip_rt, choice_algos, model_name, prefix, colorsmatrix)

Value_vs_Size_Matrix = zeros(no_sizes,no_algos);

%% Create Mat runtime vs. size

% Use a better implementation than forloop!
for i = 1:length(algos_cell)
    mat_cache = algos_cell{i};
    Value_vs_Size_Matrix(:,i) = mat_cache(1:no_sizes,1);
end

% Declare the file/title name for plot, dependent on matrix and error
title_name = sprintf('Runtime vs. Size on Model %s', model_name);
file_name = sprintf('Runtime_vs_Size_Model%s', model_name);
ylabel_str = 'Runtime (in sec)'; %sprinf('%s of the reconstructed signal', choice_errortypes{l});

% You plot the column vectors (runtime vs. size) and the different plots are for the different
% algos
[sorted_size_xaxis_rt, sorted_ind] = sort(size_xaxis_rt);
plotfrommat(sorted_size_xaxis_rt, Value_vs_Size_Matrix(sorted_ind,:), choice_algos, ...
    '', strcat(prefix, file_name), title_name, dimvalue_descrip_rt, ...
    ylabel_str, colorsmatrix);
end
