% Library with names for the different parameters/settings/algorithms
max_sparsity = .5;

%error_types_names = {'errors_L1', 'errors_L2','errors_support', 'diffs_sparsity'};
error_types_names = {'L1', 'L2', 'support'};
model_types_names = {'small_graph'};
algos_names = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', 'cvx_hot_start_lp','cvx_single_block_L_infty'...
    'cvx_random_sample_L_infty', 'cvx_mult_blocks_L_infty','cvx_block_descent_L_infty','cvx_entropy'}; % the ones taking block into account

matrix_sizes = [];
    
for no_rows=2:5
    for no_cols = 2:5
        for no_shroutes = 2:4
            total_routes = (no_rows*no_cols-1)*no_shroutes;
            max_spars = ceil(.1*total_routes);
            for spars = no_shroutes:3:max_spars
                % Spars stands for the number of nonzero routes you choose
                % at each origin
                matrix_sizes = [matrix_sizes; no_rows no_cols no_shroutes spars];
            end
        end
    end
end

    
% each row is one size triple + sparsity measure
%matrix_sizes = [2 2 2 2; 2 2 2 3; 2 2 2 4; 3 3 2 2; 3 3 2 3; ...
%    3 3 3 4; 4 4 2 2; 4 4 3 3; 4 4 3 4; 5 5 2 2; 5 5 2 3; 5 5 2 4; 5 5 3 2; 5 5 3 3; 5 5 3 4]; 

sparsity_sizes = [0.0 0.05; 0.05 0.1; 0.1 0.5; 0.5 1.0];

