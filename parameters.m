% The parameters for the file system structure, etc.
user = getenv('USER');
addpath 'lbfgsb-matlab/src';
if strcmp(user,'cathywu') == 1
    python = '/usr/local/bin/python';
    base_directory = './data-local/';
    addpath '~/mosek/7/toolbox/r2012a';
elseif strcmp(user,'richard') == 1
    python = 'python';
    base_directory = './data-local/';
else
    python = 'LD_LIBRARY_PATH= python';
    % base_directory = '~/Dropbox/traffic/data/';
    base_directory = '~/convex-project/data/';
    addpath '~/mosek/7/toolbox/r2009b';
end

mode = 'REAL'; % DEBUG, REAL

raw_directory = [base_directory, 'raw/'];
param_directory = [base_directory, 'params/'];
output_directory = [base_directory, 'output/'];
metrics_directory = [base_directory, 'metrics/'];
graphs_directory = [base_directory, 'graphs/'];

tests = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', ...
    'cvx_hot_start_lp', 'cvx_block_descent_L_infty', ...
    'cvx_random_sample_L_infty'};
% tests = {'cvx_random_sample_L_infty_hot_start'};

% Library with names for the different parameters/settings/algorithms
max_sparsity = .5;

%error_types_names = {'errors_L1', 'errors_L2','errors_support', 'diffs_sparsity'};
error_types_names = {'L1 error', 'L2 error', 'support error'};
type_names = {'traffic', 'random'};

model_types_names = containers.Map();
model_types_names('traffic') = {'small_graph'};
model_types_names('random') = {'gaussian'};

% algos_names = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', 'cvx_hot_start_lp','cvx_single_block_L_infty'...
%     'cvx_random_sample_L_infty', 'cvx_mult_blocks_L_infty','cvx_block_descent_L_infty','cvx_entropy'}; % the ones taking block into account

algos_names = tests;

matrix_sizes = containers.Map();

%% Traffic Matrix
matrix_sizes('traffic') = [];
    
for no_rows=2:5
    for no_cols = 2:5
        for no_shroutes = 2:4
            total_routes = (no_rows*no_cols-1)*no_shroutes;
            max_spars = ceil(.1*total_routes);
            for spars = no_shroutes:3:max_spars
                % Spars stands for the number of nonzero routes you choose
                % at each origin
                matrix_sizes('traffic') = [matrix_sizes('traffic'); ...
                    no_rows no_cols no_shroutes spars];
            end
        end
    end
end

% For now, we are not considering the traffic matrix
% matrix_sizes('traffic') = [2 2 2 2; 2 2 2 3;];
    
% each row is one size triple + sparsity measure
%matrix_sizes = [2 2 2 2; 2 2 2 3; 2 2 2 4; 3 3 2 2; 3 3 2 3; ...
%    3 3 3 4; 4 4 2 2; 4 4 3 3; 4 4 3 4; 5 5 2 2; 5 5 2 3; 5 5 2 4; 5 5 3 2; 5 5 3 3; 5 5 3 4]; 

sparsity_values = linspace(0.1, 0.5, 9);
sparsity_sizes = [sparsity_values', sparsity_values' + 0.05];

% num_constraints = vec(1);
% num_blocks = vec(2);
% num_vars_per_block = vec(3);
% num_nonzeros = vec(4);

%% Random matrix
matrix_sizes('random') = [];

for no_constraints=10:15
    for no_blocks = 2:3
        for no_vars_per_block = 10:12
            for sparsity = sparsity_values
                % Spars stands for the number of nonzero routes you choose
                % at each origin
                no_nonzeros = max(no_blocks, ...
                    floor(no_blocks * no_vars_per_block * sparsity));
                matrix_sizes('random') = [matrix_sizes('random'); no_constraints ...
                    no_blocks no_vars_per_block no_nonzeros];
            end
        end
    end
end

% Run subset of modes we care about to reduce computation time
if strcmp(mode,'DEBUG') == 1
    num_subsamples = 40;
    if length(matrix_sizes('random')) > num_subsamples
        p = randperm(length(matrix_sizes('random')));
        temp = matrix_sizes('random');
        matrix_sizes('random') = temp(p(1:num_subsamples), :);
    end
end