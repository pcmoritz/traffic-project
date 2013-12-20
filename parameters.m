% The parameters for the file system structure, etc.
mode = 'REAL'; % DEBUG, REAL, SMALL, PHASE_TRANSITION
repeat = 10;
cvx_solver mosek;

user = getenv('USER');
addpath 'lbfgsb-matlab/src';
if strcmp(user,'cathywu') == 1
    python = '/usr/local/bin/python';
    base_directory = './data-local/';
    addpath '~/mosek/7/toolbox/r2012a';
elseif strcmp(user,'richard') == 1
    python = 'python';
    base_directory = './data-local/';
elseif strcmp(user,'viveoistrach')==1
    python = 'LD_LIBRARY_PATH= python';
    % base_directory = '~/Dropbox/traffic/data/';
    base_directory = '';
    addpath '~/mosek/7/toolbox/r2009b';
else    
    python = 'LD_LIBRARY_PATH= python';
    % base_directory = '~/Dropbox/traffic/data/';
    base_directory = '/media/bee9be82-8dd8-4b1b-8de5-d55366dbd000/drop-box/Dropbox/traffic/data/';
    addpath '~/mosek/7/toolbox/r2009b';
end

raw_directory = [base_directory, 'raw/'];
param_directory = [base_directory, 'params/'];
output_directory = [base_directory, 'output-pcmoritz/'];
metrics_directory = [base_directory, 'metrics/'];
graphs_directory = [base_directory, 'graphs/'];

tests = {'cvx_unconstrained_L1', 'cvx_L2', 'cvx_weighted_L1'}; %, 'cvx_entropy', 'cvx_oracle', 'cvx_raw'
    
    %'cvx_L2',...
%    'cvx_random_sample_L_infty_hot_start'}; %,'cvx_random_sample_L_infty_hot_start_update','cvx_random_sample_L_infty_hot_start_uniform'};

    %'cvx_hot_start_lp', 'cvx_block_descent_L_infty', ...
% tests = {'cvx_elastic_net'};
% tests = {'cvx_random_sample_min_cardinality'};
% tests = {'cvx_rs_constant_L1L2plus_noupdate'};
% tests = {'cvx_rs_constant_L1uniform_noupdate_test'};

if strcmp(mode, 'PHASE_TRANSITION') == 1
    tests = {'cvx_unconstrained_L1'};
    tests = {'cvx_random_sample_L_infty_hot_start_update'}
end

algo_names = containers.Map();
algo_names('cvx_L2') = 'constrained L2';
algo_names('cvx_unconstrained_L1') = 'unconstrained L1';
algo_names('cvx_weighted_L1') = 'weighted L1';
algo_names('cvx_random_sample_L_infty_hot_start') = 'random sampling';
algo_names('cvx_block_descent_L_infty') = 'block descent';
algo_names('cvx_entropy') = 'entropy';
algo_names('cvx_hot_start_lp') = 'simple block';
algo_names('cvx_rs_constant_L1L2plus_noupdate') = 'random sampling L1+L2';

% Library with names for the different parameters/settings/algorithms
max_sparsity = .5;

%error_types_names = {'errors_L1', 'errors_L2','errors_support', 'diffs_sparsity'};
error_types_names = {'L1 error', 'L2 error', 'support error'};
type_names = {'traffic_O', 'traffic_OD', 'traffic_augmented', 'random'};

model_types_names = containers.Map();
model_types_names('traffic_O') = {'small_graph'};
model_types_names('traffic_OD') = {'small_graph_OD'};
model_types_names('traffic_augmented') = {'small_graph_augmented'};
model_types_names('random') = {'gaussian'};

% algos_names = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', 'cvx_hot_start_lp','cvx_single_block_L_infty'...
%     'cvx_random_sample_L_infty', 'cvx_mult_blocks_L_infty','cvx_block_descent_L_infty','cvx_entropy'}; % the ones taking block into account

algos_names = tests;

matrix_sizes = containers.Map();

% %% Traffic Matrix
matrix_sizes('traffic') = [];

% for no_rows=2:5
%     for no_cols = 2:5
%         for no_shroutes = 2:4
%             total_routes = (no_rows*no_cols-1)*no_shroutes;
%             max_spars = ceil(.1*total_routes);
%             for spars = no_shroutes:3:max_spars
%                 % Spars stands for the number of nonzero routes you choose
%                 % at each origin
%                 matrix_sizes('traffic') = [matrix_sizes('traffic'); ...
%                     no_rows no_cols no_shroutes spars];
%             end
%         end
%     end
% end

% For now, we are not considering the traffic matrix

 %matrix_sizes('traffic') = [2 2 2 2; 2 2 2 3; 3 2 3 2; 3 2 3 3];
    
% each row is one size triple + sparsity measure
% matrix_sizes = [2 2 2 2; 2 2 2 3; 2 2 2 4; 3 3 2 2; 3 3 2 3; ...
%    3 3 3 4; 4 4 2 2; 4 4 3 3; 4 4 3 4; 5 5 2 2; 5 5 2 3; 5 5 2 4; 5 5 3 2; 5 5 3 3; 5 5 3 4]; 

% num_constraints = vec(1);
% num_blocks = vec(2);
% num_vars_per_block = vec(3);
% num_nonzeros = vec(4);

% %% Random matrix
 matrix_sizes('random') = [];
 
sparsity_values = [0.02, 0.04, 0.06, 0.08, 0.10, 0.14];
sparsity_sizes = [sparsity_values', sparsity_values' + 0.05];

for no_blocks = 5
    for no_vars_per_block = 10:10:40
        for no_constraints = [1:5] * ceil(no_vars_per_block/6)
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

if strcmp(mode,'SMALL') == 1
    p = matrix_sizes('random');
    % matrix_sizes('random') = [155 10 100 max(10, floor(10 * 100 * 0.06))];
    matrix_sizes('random') = [175 10 100 max(10, floor(10 * 100 * 0.06))];
    repeat = 250;
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
