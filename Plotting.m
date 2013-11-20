% Plotting the errors

% Load colors matrix
load('colorsmatrix.mat');
% Loads all the names
run('library_names'); 

% Which look like this but could be changed now
%algos_names = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', 'cvx_hot_start_lp','cvx_single_block_L_infty'...
%    'cvx_random_sample_L_infty', 'cvx_mult_blocks_L_infty','cvx_block_descent_L_infty','cvx_entropy'}; % the ones taking block into account
%error_types_names = {'errors_L1', 'errors_L2','errors_support', 'diffs_sparsity'};
%model_types_names = {'base_case', 'OD', 'augmented', 'random'};


% Get the averaged versions
% I want these plots:
% Different files: different error types, different matrices
% legend: always algos,
% y-axis: error, runtime
% x_axis: size, sparsity

% Algorithms I want to plot
choice_algos_ind = [1,3,5,6]; % <------ USER SETS which algos to plot
choice_algos = algos_names(choice_algos_ind); % write the actually tested algorithms into a cell array
no_algos = length(choice_algos_ind);

% Errors I want to plot
choice_errortypes_ind = [1,3]; % <------- USER SETS which errors to plot
choice_errortypes = error_types_names(choice_errortypes_ind);
no_errortypes = length(choice_errortypes);

% Matrices I want to plot
choice_models_ind = [1,4]; % < ---------- USER SETS which models to plot
choice_models = model_types_names(choice_models_ind);
no_models = length(choice_models);
% models = cell(no_models); % Going to be a cell where everything is ordered wrt. model type

% Matrix sizes I want to plot

% Kind of plots I want
plottypes_names = {'Error vs. Size', 'Error vs. Sparsity', 'Runtime vs. Size', 'Runtime vs. Sparsity'};
choice_plots_ind = [1,3];
choice_plottypes = plottypes_names(choice_plots_ind);
no_plottypes = length(choice_plots_ind);


% Temporary cells storing everything
for k= 1:no_models
    
    % Go to directory of the model
    for m = 1:no_algos
        for l = 1:no_errortypes
            
            % Average over all samples which have given fixed error, algos, models,
            % size, sparsity 
            
        end
    end
end

for n = 1:no_plottypes
    if choice_plots_ind(n) == 1
        % Create Mat errors vs. size
        error_size
        
    elseif choice_plots_ind(n) == 2
        % Create Mat errors vs. sparsity
    elseif choice_plots_ind(n) == 3
        % Create Mat runtime vs. size
    elseif choice_plots_ind(n) == 4
        % Create Mat runtime vs. sparsity
    end
    
    
    % Declare the file/title name, dependent on matrix and error
    title_name = sprintf('%s %s conducted on %s', models{k}.matrix_type, error_types{l}, datetime);
    file_name = sprintf('%s_%s_%s.mat', models{k}.matrix_type, error_types{l}, datetime);
    ylabel_str = sprinf('%s error of the reconstructed signal', error_types{l});
    
    % You plot the column vectors (error vs. dimensions) and the different plots are for the different
    % algos
    eval(['error_mat = models{k}.' sprintf(error_types{l})]);
    fig = plotfrommat(no_nodes, error_mat, choice_algos, 'Tested Algorithms', file_name, ...
        title_name, 'Number of nodes', ylabel_str, colorsmatrix);
end

