%% Sample test
clear all;

user = getenv('USER');
if strcmp(user,'cathywu') == 1
    python = '/opt/local/bin/python';
else
    python = 'python';
end

rows = 5; cols = 5; k = 2; n = 2;
command = sprintf(horzcat(['%s static_matrix.py --num_rows %d ', ...
      '--num_cols %d --num_routes_per_od %d ', ...
      '--num_nonzero_routes_per_o %d']), python, rows, cols, k, n)
system(command);

p = TestParameters();
p.rows = rows; p.cols = cols; p.nroutes = k; p.sparsity = 0;
p.model_type = 'small_graph'; % 'small_graph_random', 'small_graph_OD'

[errors_L1 errors_L2 comparisons] = small_sparse_recovery(p,{'cvx_L2'});

tests = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1', ...
    'cvx_entropy'};
    % 'cvx_hot_start_lp',...% 'cvx_block_descent_L_infty', ...

for test = tests
    o = TestOutput();
    o.test_parameters = p; o.algorithm = test{1};
    run_algorithm_test(o);
    % save this object to disk
    
    m = TestMetrics();
    m.test_output = o;
    [error_L1 error_L2 error_support real_sparsity test_sparsity] = output_to_metrics(o);
    m.error_L1 = error_L1; m.error_L2 = error_L2; 
    m.error_support = error_support; m.real_sparsity = real_sparsity;
    m.test_sparsity = test_sparsity;
end
%%
% Then to view the results test-by-test, select the test number, e.g.
% errors(2)
% comparison = comparisons(2);
% comparison{1}
