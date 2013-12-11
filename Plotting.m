% Plotting the errors 
function Plotting(prefix, all_metrics)

% Load colors matrix
load('colorsmatrix.mat');
% Loads all the parameters
run('parameters');

% Get the averaged versions
% I want these plots:
% Different files: different error types, different matrices
% legend: always algos,
% y-axis: error, runtime
% x_axis: size, sparsity


%% Set parameters which determine the plots

% Type I want to plot
plot_type = 'random';

% Algorithms I want to plot
choice_algos_ind = [1,2,3,4,5,6]; % <------ USER SETS which algos to plot
choice_algos = algos_names(choice_algos_ind); % cell of strings
no_algos = length(choice_algos_ind);

% Errors I want to plot
% choice_errortypes_ind = [1,3]; % <------- USER SETS which errors to plot
% choice_errortypes = error_types_names(choice_errortypes_ind); % cell of strings
% no_errortypes = length(choice_errortypes);
no_errortypes = 3;

% Matrices I want to plot (for now just one)
choice_models_ind = 1; % < ---------- USER SETS which models to plot
models_to_plot = model_types_names(plot_type);
choice_models = models_to_plot(choice_models_ind); % cell of strings
no_models = length(choice_models);
% models = cell(no_models); % Going to be a cell where everything is ordered wrt. model type

% Matrix sizes I want to plot
choice_sizes_ind = [1:20];
matrix_sizes_for_type = matrix_sizes(plot_type);
choice_sizes = matrix_sizes_for_type(choice_sizes_ind,:);
no_sizes = length(choice_sizes_ind);

% Sparsities I want to plot
choice_sparsities_ind = [1,2,3,4];
choice_sparsities = sparsity_sizes(choice_sparsities_ind, :);
no_sparsities = length(choice_sparsities_ind);

% For random matrices plotting m vs. n, choose no_blocks and no_vars_per_block I wanne fix
plot_noblocks = 3; plot_novars = 10; 
%plot_nocols = 20; % Fix number of cols 
%no_cols = matrix_sizes_for_type(:,4); % All experiments 
% Get indeces with matrix size you want
active_indices = intersect(find(matrix_sizes_for_type(:,2) == plot_noblocks),find(matrix_sizes_for_type(:,3) == plot_novars));
constraint_sizes = matrix_sizes_for_type(active_indices,1);
% blockvar_sizes = matrix_sizes_for_type(indices,2:3); % Same no_cols might have different blocks, variables sizes
choice_constraints = unique(constraint_sizes); % well actually don't need unique here
no_constraints = length(choice_constraints);


% % Kind of plots I want
% plottypes_names = {'Error vs. Size', 'Error vs. Sparsity', 'Runtime vs. Size', 'Runtime vs. Sparsity'};
% choice_plots_ind = [1,3];
% choice_plottypes = plottypes_names(choice_plots_ind);
% no_plottypes = length(choice_plots_ind);

%% Display plotting parameters to user
disp('Plotting parameters');
disp('ALGORITHMS'); cellfun(@(x) disp(x), choice_algos);
disp('MODELS'); disp(choice_models);
disp('SIZES'); disp(choice_sizes);
disp('SPARSITIES'); disp(choice_sparsities);

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
results_constraintsblock = zeros(no_constraints,4);

for i = 1:no_algos
    % Get the chosen algorithm string
    algo = choice_algos{i};
    
    for j = 1:no_sizes
        % Get the chosen size vector
        mysize = choice_sizes(j,:);
        
        % Average all results which have the algorithm and the size
        filtered_metrics = filter_metrics(plot_type, all_metrics, mysize, algo, 0);
        averaged_m = average_metrics(filtered_metrics);
        results_sizesblock(j,:) = [averaged_m.test_output.runtime, ...
            averaged_m.error_L1, averaged_m.error_L2, averaged_m.error_support];
        
        if i == 1
            Phi_sizes(j,:) = size(averaged_m.test_output.test_parameters.Phi);
        end
        
    end
    
    % Get the ones 
    for k = 1:no_constraints
        mysize = [choice_constraints(k) plot_noblocks plot_novars];
        %myconstraints = choice_constraints(k);
        % Average all results which have 
        filtered_metrics = filter_metrics(plot_type, all_metrics, mysize, algo, 1);
        averaged_m = average_metrics(filtered_metrics);
        results_constraintsblock(k,:) = [averaged_m.test_output.runtime, ...
            averaged_m.error_L1, averaged_m.error_L2, averaged_m.error_support];        
    end
    
    for j = 1:no_sparsities
        % Get the chosen size vector
        sparsity_range = choice_sparsities(j,:);
        
        % Average all results which have the algorithm and sparsity
        relevant_metrics = {};
        for m = all_metrics
            m = m{:};
            o = m.test_output;
            p = o.test_parameters;
            if strcmp(p.type, plot_type) && p.sparsity >= sparsity_range(1) && p.sparsity < sparsity_range(2) ...
                    && strcmp(o.algorithm, algo)
                relevant_metrics{length(relevant_metrics) + 1} = m;
            end
        end
        % Get a test object which is an averaged version
        averaged_m = average_metrics(relevant_metrics);
        results_sparsityblock(j,:) = [averaged_m.test_output.runtime, ...
            averaged_m.error_L1, averaged_m.error_L2, ...
            averaged_m.error_support];
    end
    
    % Save the algo_matrix in the entire cell
    algos_cell{i} = [results_sizesblock; results_sparsityblock; results_constraintsblock];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating x_axes vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All size information:
% [Graph_rows Graph_cols ShortestRoutes_k Sparsity Phi_no_rows Phi_no_cols];
size_mat = [choice_sizes Phi_sizes];

%% For Error
% Define a function which acts upon the sizes vector choice_sizes and
% matrix_sizes and gives us the x-axis for plotting

% For now for example ratio of rows vs. columns of Phi
size_xaxis = size_mat(:,5)./size_mat(:,6);
dimvalue_descrip = 'ratio of matrix row vs. col';


%% For vs. Constraints
constraints_xaxis = choice_constraints;
dimvalue_descrip_cst = sprintf('number of constraints m with fixed %d no. of blocks and %d variables per block',plot_noblocks,plot_novars);

%% For Runtime
size_xaxis_rt = log(size_mat(:,4) + size_mat(:,5));

sparsity_xaxis = (choice_sparsities(:, 1) + choice_sparsities(:, 2)) / 2;
dimvalue_descrip_rt = 'log (m+n) of matrix phi';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating the different plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Initialize intermediate matrices overwritten in each loop
% Value_vs_Size_Matrix = zeros(no_sizes,no_algos);
% Value_vs_Sparsity_Matrix = zeros(no_sparsities,no_algos);

for l = 1:no_errortypes
    error_name = error_types_names{l};
    model_name = choice_models{:};
    if strcmp(plot_type,'random')
        model_name = 'random';
    end
    %% Create Mat errors vs. size
    plotting_err_vs_sz(no_sizes, no_algos, algos_cell, size_xaxis, dimvalue_descrip, choice_algos, l, error_name, model_name, prefix, colorsmatrix);
    
    %% Create Mat errors vs. sparsity
    plotting_err_vs_spars(no_sizes, no_algos, no_sparsities, algos_cell,sparsity_xaxis, choice_algos, l, error_name, model_name, prefix, colorsmatrix);

    %% Create Mat errors vs. no. constraints
    % Choose one no_matrix_cols 
    % For this one size
    plotting_err_vs_constraints(no_sizes, no_algos, no_sparsities, algos_cell, constraints_xaxis, dimvalue_descrip_cst, choice_algos, l, error_name, model_name, prefix, colorsmatrix, plot_noblocks, plot_novars);
end


%% Create Mat runtime vs. size
plotting_rt_vs_sz(no_sizes, no_algos, algos_cell, size_xaxis_rt, dimvalue_descrip_rt, choice_algos, model_name, prefix, colorsmatrix);
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

