%% Sample test
[errors comparisons] = small_sparse_recovery({'cvx_L2','cvx_raw',...
    'cvx_unconstrained_L1','cvx_weighted_L1'},'small_graph_OD');

% Then to view the results test-by-test, select the test number, e.g.
% errors(2)
% comparison = comparisons(2);
% comparison{1}