% Library with names for the different parameters/settings/algorithms

%error_types_names = {'errors_L1', 'errors_L2','errors_support', 'diffs_sparsity'};
error_types_names = {'L1', 'L2', 'support'};
model_types_names = {'small_graph'};
algos_names = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', 'cvx_hot_start_lp','cvx_single_block_L_infty'...
    'cvx_random_sample_L_infty', 'cvx_mult_blocks_L_infty','cvx_block_descent_L_infty','cvx_entropy'}; % the ones taking block into account
matrix_sizes = [2 2 2; 3 3 2; 4 4 2; 4 4 3; 5 5 2; 5 5 3]; % each row is one size triple
sparsity_sizes = 0.1:.05:.5;