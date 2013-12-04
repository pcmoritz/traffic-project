%% Hot start recovery for L_infinity with one block

% call with
% [errors comparisons] = small_sparse_recovery({'cvx_hot_start_lp'},'small_graph')

% execute
% addpath '~/mosek/7/toolbox/r2009b'

function result = cvx_hot_start_lp(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    result = solve_block_hot_start_lp(Phi, zeros(n, 1), f, [1, n]);

    fprintf('\n')
end