% Plotting the errors 
function Plotting(averaged_metrics)

% Load colors matrix
load('colorsmatrix.mat');
% Loads all the names
run('library_names');

% Get the averaged versions
% I want these plots:
% Different files: different error types, different matrices
% legend: always algos,
% y-axis: error, runtime
% x_axis: size, sparsity


%% Set parameters which determine the plots

% Algorithms I want to plot
choice_algos_ind = [1,2,3,4]; % <------ USER SETS which algos to plot
choice_algos = algos_names(choice_algos_ind); % cell of strings
no_algos = length(choice_algos_ind);

% Errors I want to plot
% choice_errortypes_ind = [1,3]; % <------- USER SETS which errors to plot
% choice_errortypes = error_types_names(choice_errortypes_ind); % cell of strings
% no_errortypes = length(choice_errortypes);
no_errortypes = 3;

% Matrices I want to plot (for now just one)
choice_models_ind = 1; % < ---------- USER SETS which models to plot
choice_models = model_types_names(choice_models_ind); % cell of strings
no_models = length(choice_models);
% models = cell(no_models); % Going to be a cell where everything is ordered wrt. model type

% Matrix sizes I want to plot
choice_sizes_ind = [1,2,3,4,5,6];
choice_sizes = matrix_sizes(choice_sizes_ind,:);
no_sizes = length(choice_sizes_ind);

% Sparsities I want to plot
choice_sparsities_ind = [1,2,3,4,5];
choice_sparsities = sparsity_sizes(choice_sparsities_ind);
[no_sparsities, ~] = size(choice_sparsities);


% % Kind of plots I want
% plottypes_names = {'Error vs. Size', 'Error vs. Sparsity', 'Runtime vs. Size', 'Runtime vs. Sparsity'};
% choice_plots_ind = [1,3];
% choice_plottypes = plottypes_names(choice_plots_ind);
% no_plottypes = length(choice_plots_ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Getting averaged data points for each plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% I have one matrix per algorithm
% The algos_cell saves all these matrices into one cell :D

% Initialize cells to be filled
algos_cell = cell(no_algos, 1);
Phi_sizes = zeros(no_sizes, 2);
% Initialize intermediate matrices
results_sizesblock = zeros(no_sizes,4);%no_errortypes+1);
results_sparsityblock = zeros(no_sparsities,4);% no_errortypes+1);

for m = 1:no_algos
    
    % Get the chosen algorithm string
    algo = choice_algos{m};
    
    for p = 1:no_sizes
        
        sparsity = default_sparsity;
        
        % Get the chosen size vector
        mysize = choice_sizes(p,:);
        
        % Get a test object which is an averaged version
        key = sprintf('%s::%s::%.3f::%d-%d-%d', choice_models{:}, algo, sparsity, int64(mysize));
        assert(isKey(averaged_metrics, key), sprintf('%s not found in averaged_metrics', key));
        averaged_m = averaged_metrics(key);
        results_sizesblock(p,:) = [averaged_m.test_output.runtime, averaged_m.error_L1, ...
            averaged_m.error_L2, averaged_m.error_support];
        
        if m == 1
            Phi_sizes(p,:) = size(averaged_m.test_output.test_parameters.Phi);
        end
        
    end
    
    for q = 1:no_sparsities
        
        mysize = default_size;
        % Get the chosen size vector
        sparsity = choice_sparsities(q);
        
        % Get a test object which is an averaged version 
        key = sprintf('%s::%s::%.3f::%d-%d-%d', choice_models{:}, algo, sparsity, mysize);
        assert(isKey(averaged_metrics, key), sprintf('%s not found in averaged_metrics', key));
        averaged_m = averaged_metrics(key);
        results_sparsityblock(q,:) = [averaged_m.test_output.runtime, averaged_m.error_L1, ...
            averaged_m.error_L2, averaged_m.error_support];
        
    end
    
    % Save the algo_matrix in the entire cell
    algos_cell{m} = [results_sizesblock; results_sparsityblock];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating x_axes vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% All size information:
% [Graph_rows Graph_cols ShortestRoutes_k Phi_no_rows Phi_no_cols];
size_mat = [choice_sizes Phi_sizes];

%% For Error
% Define a function which acts upon the sizes vector choice_sizes and
% matrix_sizes and gives us the x-axis for plotting

% For now for example ratio of rows vs. columns of Phi
size_xaxis = size_mat(:,4)./size_mat(:,5);
dimvalue_descrip = 'ratio of matrix row vs. col';

%% For Runtime
size_xaxis_rt = log(size_mat(:,4) + size_mat(:,5));

sparsity_xaxis = choice_sparsities;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating the different plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize intermediate matrices overwritten in each loop
Value_vs_Size_Matrix = zeros(no_sizes,no_algos);
Value_vs_Sparsity_Matrix = zeros(no_sparsities,no_algos);

for l = 1:no_errortypes
    %% Create Mat errors vs. size
    
    % Use a better implementation than forloop!
    % Put all values in a matrix prepare for plotting
    for i = 1:length(algos_cell)
        mat_cache = algos_cell{i};
        Value_vs_Size_Matrix(:,i) = mat_cache(1:no_sizes,l+1);
    end
    
    % Declare the file/title name for plot, dependent on matrix and error
    title_name = sprintf('%s vs. Size on Model %s with fixed Sparsity %f', error_types_names{l}, choice_models{:}, default_sparsity);
    file_name = sprintf('%s_vs_Size_Model%s_Sparsity%d.fig',  error_types_names{l}, choice_models{:}, default_sparsity);
    ylabel_str = error_types_names{l}; %sprinf('%s of the reconstructed signal', choice_errortypes{l});
    
    % You plot the column vectors (error vs. dimensions) and the different plots are for the different
    % algos
    % eval(['error_mat = models{k}.' sprintf(error_types{l})]);
    plotfrommat(size_xaxis, Value_vs_Size_Matrix, choice_algos, 'Tested Algorithms', file_name, ...
        title_name, dimvalue_descrip, ylabel_str, colorsmatrix);
    
    %% Create Mat errors vs. sparsity

    % Put all values in a matrix prepare for plotting
    for i = 1:length(algos_cell)
        mat_cache = algos_cell{i};
        Value_vs_Sparsity_Matrix(:,i) = mat_cache(no_sizes+1:no_sizes+no_sparsities,l+1);
    end
    
    % Declare the file/title name for plot, dependent on matrix and error
    title_name = sprintf('%s vs. Sparsity on Model %s with fixed Size %d', error_types_names{l}, choice_models{:}, default_size);
    file_name = sprintf('%s_vs_Sparsity_Model%s_Size%d.fig', error_types_names{l}, choice_models{:}, default_size);
    ylabel_str =  error_types_names{l}; %sprinf('%s of the reconstructed signal',);
    
    % You plot the column vectors (error vs. sparsity) and the different plots are for the different
    % algos
    plotfrommat(size_xaxis(1), Value_vs_Sparsity_Matrix, choice_algos, 'Tested Algorithms', file_name, ...
        title_name, 'Sparsity', ylabel_str, colorsmatrix);
end


%% Create Mat runtime vs. size

% Use a better implementation than forloop!
for i = 1:length(algos_cell)
    mat_cache = algos_cell{i};
    Value_vs_Size_Matrix(:,i) = mat_cache(1:no_sizes,1);
end

% Declare the file/title name for plot, dependent on matrix and error
title_name = sprintf('Runtime vs. Size on Model %s with fixed Size %d', choice_models{:}, default_sparsity);
file_name = sprintf('Runtime_vs_Size_Model%s_Sparsity%d.fig', choice_models{:}, default_sparsity);
ylabel_str = 'Runtime (in sec)'; %sprinf('%s of the reconstructed signal', choice_errortypes{l});

% You plot the column vectors (runtime vs. size) and the different plots are for the different
% algos
plotfrommat(size_xaxis_rt, Value_vs_Size_Matrix, choice_algos, 'Tested Algorithms', file_name, ...
    title_name, dimvalue_descrip, ylabel_str, colorsmatrix);


%{
%% Create Mat runtime vs. sparsity

% Use a better implementation than forloop!
for i = 1:length(algos_cell)
    mat_cache = algos_cell{i};
    Value_vs_Sparsity_Matrix(:,i) = mat_cache(:,1+no_errortypes+1);
end

% Declare the file/title name for plot, dependent on matrix and error
title_name = sprintf('Runtime vs. Sparsity on Model %s with fixed Size %d', choice_models, default_size);
file_name = sprintf('Runtime_vs_Sparsity_Model%s_Size%d.fig', choice_models, default_size);
ylabel_str = 'Runtime (in sec)'; %sprinf('%s of the reconstructed signal', choice_errortypes{l});

% You plot the column vectors (runtime vs. sparsity) and the different lines are for the different
% algos
plotfrommat(sparsity_xaxis, Value_vs_Sparsity_Matrix, choice_algos, 'Tested Algorithms', file_name, ...
    title_name, 'Sparsity', ylabel_str, colorsmatrix);

end
%}

