%% Sample test
clear all;

user = getenv('USER');
if strcmp(user,'cathywu') == 1
    python = '/opt/local/bin/python';
else
    python = 'python';
end

rows = 5; cols = 5; k = 2;
command = sprintf('%s static_matrix.py %d %d %d', python, rows, cols, k);
system(command);

p = TestParameters();
p.rows = rows; p.cols = cols; p.nroutes = k; p.sparsity = 0;

[errors_L1 errors_L2 comparisons] = small_sparse_recovery(p,{'cvx_L2',...
    'cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1',...
    'cvx_random_sample_L_infty'},'small_graph');


%% 
[errors_L1 errors_L2 comparisons] = small_sparse_recovery({'cvx_L2',...
    'cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1',...
    'cvx_random_sample_L_infty'},'small_graph_OD');

% Then to view the results test-by-test, select the test number, e.g.
% errors(2)
% comparison = comparisons(2);
% comparison{1}
