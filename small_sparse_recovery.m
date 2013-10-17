%% cvx code for sparse recovery of on small graphs
clear all;

%% Read in graph
% load('small-graph.mat','G')
Phi = abs(randn(10,10));
f = abs(randn(10,1));

%% Define parameters
n = 10;

%% cvx
cvx_begin
    variable a(n)
    minimize( square_pos(norm(Phi * a - f, 2)) + inv_pos(norm( a, Inf )) )
    subject to
    a >= 0;
cvx_end
