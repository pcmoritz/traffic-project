% Plotting the errors
function filtered_metrics_const = Plotting(prefix, all_metrics)
filtered_metrics_const= [];
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
%plot_type = input('Choose plot type random or traffic:');
plot_type = 'random';
%plot_type = 'traffic';
if strcmp(plot_type,'random')
    model_type = 'random';
    model_name = 'gaussian';
elseif strcmp(plot_type, 'traffic')
    %model_type = 'traffic_OD'; % traffic model with added OD pairs
    model_type = 'traffic_O'; % original traffic model
    % model_type = 'traffic_augmented'; - DOES NOT WORK
    model_name = model_types_names(model_type);
end

% Errors I want to plot
% choice_errortypes_ind = [1,3]; % <------- USER SETS which errors to plot
% choice_errortypes = error_types_names(choice_errortypes_ind); % cell of strings
% no_errortypes = length(choice_errortypes);
no_errortypes = 3;

% Matrices I want to plot (for now just one)
%choice_models_ind = 1; % < ---------- USER SETS which models to plot


% choice_models = models_to_plot(choice_models_ind); % cell of strings
% no_models = length(choice_models);
% models = cell(no_models); % Going to be a cell where everything is ordered wrt. model type

% Matrix sizes I want to plot
% Run parameters, check matrix_sizes and plotting over all sizes we have.
matrix_sizes_for_type = matrix_sizes(plot_type);
matrix_sizes_for_type = unique(matrix_sizes_for_type(:, 1:3),'rows'); % so that the nonzeros are not counted as different sizes
choice_sizes_ind = 1:size(matrix_sizes_for_type,1);
choice_sizes = matrix_sizes_for_type(choice_sizes_ind,:);
no_sizes = length(choice_sizes_ind);

% Sparsities I want to plot
choice_sparsities_ind = [1,2,3,4];
choice_sparsities = sparsity_sizes(choice_sparsities_ind, :);
no_sparsities = length(choice_sparsities_ind);

%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% USER INTERFACE TO CHOOSE FIX sizes/sparsity; Algorithms
%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Algorithms I want to plot
disp(' Algorithms ');
disp(char(algos_names));
%choice_algos_ind = [1,2,3,4]; % <------ USER SETS which algos to plot
%choice_algos_ind = 100;
choice_algos_ind = input('Choose the algorithms you want to plot \n by typing e.g. [1,3,4]: ');
if isempty(find(choice_algos_ind > length(algos_names))) == 0 || isempty(choice_algos_ind)
    choice_algos_ind = 1:length(algos_names);
end
choice_algos = algos_names(choice_algos_ind); % cell of strings
no_algos = length(choice_algos_ind);

% Fixed sparsity for over sizes plot
%disp(fprintf('\n Generated sparsity sizes:'));
%disp(sparsity_sizes);
%plot_sparsity = input('Type in a sparsity range e.g. [0.1 0.2]');
plot_sparsity = [0.03 0.07];

% Let user choose no blocks and variables and constraints to plot
if strcmp(plot_type,'random')
    disp(fprintf('\n Index  #const  #blocks  #vars'));
else
    disp(fprintf('\n Index  #rows #cols #ShR'));
end
disp([choice_sizes_ind' matrix_sizes_for_type])
plot_userwants_ind = input('Please choose one of the above sizes \n by choosing the leftest entry:');

if strcmp(plot_type,'random')
    % For random matrices plotting m vs. n, choose no_blocks and no_vars_per_block I wanne fix
    plot_noblocks = matrix_sizes_for_type(plot_userwants_ind,2);
    plot_novars = matrix_sizes_for_type(plot_userwants_ind,3);
    plot_noconstraints = matrix_sizes_for_type(plot_userwants_ind,1);
    %plot_noblocks = 4; plot_novars = 10;
    %plot_noconstraints = 10; %.2*plot_noblocks*plot_novars;
    % Get indeces with matrix size you want for the error vs. m plots
    active_indices = intersect(find(matrix_sizes_for_type(:,2) == plot_noblocks),find(matrix_sizes_for_type(:,3) == plot_novars));
    constraint_sizes = matrix_sizes_for_type(active_indices,1);
    % blockvar_sizes = matrix_sizes_for_type(indices,2:3); % Same no_cols might have different blocks, variables sizes
    choice_constraints = unique(constraint_sizes); % well actually don't need unique here
    no_constraints = length(choice_constraints);
else
    % For traffic matrices choose one size you want for sparsity plot
    plot_size =  matrix_sizes_for_type(plot_userwants_ind,:);
    % plot_size_ind = 1; % !!! Hm still a problem!
    % plot_size = matrix_sizes_for_type(plot_size_ind);
    no_constraints = 1; % to avoid errors
    choice_constraints = 1;
end




%% Display plotting parameters to user
disp('Plotting parameters');
disp('ALGORITHMS'); cellfun(@(x) disp(x), choice_algos);
disp('MODELS'); disp(model_name);
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
results_sizesblock = zeros(no_sizes, 4, 2);%no_errortypes+1);
results_sparsityblock = zeros(no_sparsities, 4, 2);% no_errortypes+1);
results_constraintsblock = zeros(no_constraints, 4, 2);

for i = 1:no_algos
    % Get the chosen algorithm string
    algo = choice_algos{i};
    
    for j = 1:no_sizes
        % Get the chosen size vector
        mysize = choice_sizes(j,1:3);
        sparsity_range = plot_sparsity;
        
        % Average all results which have the algorithm and sparsity
        relevant_metrics = {};
        for m = all_metrics
            m = m{:};
            o = m.test_output;
            p = o.test_parameters;
            if strcmp(p.model_type, model_name) && p.sparsity >= sparsity_range(1) && p.sparsity < sparsity_range(2) ...
                    && strcmp(o.algorithm, algo)
                relevant_metrics{length(relevant_metrics) + 1} = m;
            end
        end
        
        % Average all results which have the algorithm and the size
        filtered_metrics = filter_metrics(model_name, relevant_metrics, mysize, algo, 0);
        [averaged_m, stddev_m] = average_metrics(filtered_metrics);
        results_sizesblock(j,:,:) = [averaged_m.test_output.runtime, ...
            averaged_m.error_L1, averaged_m.error_L2, averaged_m.error_support; ...
            stddev_m.test_output.runtime, ...
            stddev_m.error_L1, stddev_m.error_L2, stddev_m.error_support]';
        
        if i == 1
            Phi_sizes(j,:) = size(averaged_m.test_output.test_parameters.Phi);
        end
        
    end
    
    if strcmp(plot_type,'random')
        % Get the ones
        for k = 1:no_constraints
            sparsity_range = plot_sparsity;
            mysize = [choice_constraints(k) plot_noblocks plot_novars];
            %myconstraints = choice_constraints(k);
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
            
            % Average all results which have 
        filtered_metrics_const = filter_metrics(model_name, relevant_metrics, mysize, algo, 1);
        [averaged_m, stddev_m] = average_metrics(filtered_metrics_const);
        results_constraintsblock(k,:,:) = [averaged_m.test_output.runtime, ...
            averaged_m.error_L1, averaged_m.error_L2, averaged_m.error_support; ...
            stddev_m.test_output.runtime, ...
            stddev_m.error_L1, stddev_m.error_L2, stddev_m.error_support]';

        end
    end
    for j = 1:no_sparsities
        % Get the chosen size vector
        if strcmp(plot_type,'random')
            mysize = [plot_noconstraints plot_noblocks plot_novars];
        else
            mysize = plot_size; %choice_sizes(plot_size, 1:3);
        end
        sparsity_range = choice_sparsities(j,:);
        
        % Average all results which have the algorithm and sparsity
        % Filter by sparsity
        relevant_metrics = {};
        for m = all_metrics
            m = m{:};
            o = m.test_output;
            p = o.test_parameters;
            if strcmp(p.model_type, model_name) && p.sparsity >= sparsity_range(1) && p.sparsity < sparsity_range(2) ...
                    && strcmp(o.algorithm, algo)
                relevant_metrics{length(relevant_metrics) + 1} = m;
            end
        end
        
        % Filter by sizes
        filtered_metrics = filter_metrics(model_name, relevant_metrics, mysize, algo, 1);
        
        % Get a test object which is an averaged version
        [averaged_m, stddev_m] = average_metrics(filtered_metrics);
        results_sparsityblock(j,:,:) = [averaged_m.test_output.runtime, ...
            averaged_m.error_L1, averaged_m.error_L2, ...
            averaged_m.error_support; ...
            stddev_m.test_output.runtime, ...
            stddev_m.error_L1, stddev_m.error_L2, stddev_m.error_support]';

        if j == 1 && strcmp(plot_type, 'traffic')
            plot_noconstraints_traffic = size(averaged_m.test_output.test_parameters.Phi,1);
        end
    end
    
    % Save the algo_matrix in the entire cell
    algos_cell{i} = [results_sizesblock; results_sparsityblock; results_constraintsblock];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating x_axes vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% All size information:
% For random:
% [No_blocks No_vars_perBlock No_nonzeros Phi_no_rows Phi_no_cols]
% For traffic:
% [Graph_rows Graph_cols ShortestRoutes_k No_nonzeroroutes Phi_no_rows Phi_no_cols];
size_mat = [choice_sizes Phi_sizes];

%% For Error
% Define a function which acts upon the sizes vector choice_sizes and
% matrix_sizes and gives us the x-axis for plotting

% For now for example ratio of rows vs. columns of Phi
if strcmp(plot_type,'random')==1
    size_xaxis = size_mat(:,4)./size_mat(:,5); %(mean(plot_sparsity)*log(1/mean(plot_sparsity)));
else
    size_xaxis = size_mat(:,4)./size_mat(:,5);
end
dimvalue_descrip = 'ratio of matrix row vs. col';


%% For vs. Constraints
constraints_xaxis = choice_constraints;
dimvalue_descrip_cst = 'number of constraints m'; %sprintf( with \n fixed %d no. of blocks and \n %d variables per block',plot_noblocks,plot_novars);

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
    %model_name = choice_models{:};
    %     if strcmp(plot_type,'random')
    %         model_name = 'random';
    %     else
    %         model_name = 'traffic';
    %     end
    %% Create Mat errors vs. size
    if strcmp(plot_type, 'random')
        file_name = sprintf('%s_vs_Size_S%.2f_%s',  ...
        error_name, mean(plot_sparsity), char(model_name));
    else
        file_name = sprintf('%s_vs_Size_S%.2f_%s',  ...
        error_name, mean(plot_sparsity), char(model_name));
    end
    plotting_err_vs_sz(no_sizes, no_algos, algos_cell, size_xaxis, dimvalue_descrip, choice_algos, l, error_name, char(model_name), prefix, colorsmatrix, file_name);

    %% Create Mat errors vs. sparsity
    if strcmp(plot_type, 'random')
        file_name = sprintf('%s_vs_Sparsity_B%d_V%d_C%d_%s',  ...
            error_name, plot_noblocks, plot_novars, plot_noconstraints,char(model_name));
    else
        file_name = sprintf('%s_vs_Sparsity_GR%d_GC%d_C%d_%s',  ...
            error_name, plot_size(1), plot_size(2), plot_noconstraints_traffic,char(model_name));
    end
    plotting_err_vs_spars(no_sizes, no_algos, no_sparsities, algos_cell,sparsity_xaxis, choice_algos, l, error_name, char(model_name), prefix, colorsmatrix, file_name);
    
    %% Create Mat errors vs. no. constraints
    % Choose one no_matrix_cols
    % For this one size
    if strcmp(plot_type,'random') == 1
        file_name = sprintf('%s_vs_Constraints_B%d_V%d_S%.2f_%s',  ...
            error_name, plot_noblocks, plot_novars, mean(plot_sparsity), char(model_name));
        plotting_err_vs_constraints(no_sizes, no_algos, no_sparsities, algos_cell, constraints_xaxis, dimvalue_descrip_cst, choice_algos, l, error_name, char(model_name), prefix, colorsmatrix, file_name);
    end
end


%% Create Mat runtime vs. size
%plotting_rt_vs_sz(no_sizes, no_algos, algos_cell, size_xaxis_rt, dimvalue_descrip_rt, choice_algos, char(model_name), prefix, colorsmatrix);
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

