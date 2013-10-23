%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
load('small_graph.mat')
Phi = phi;
real_a = alpha;
m = size(Phi,1);
n = size(Phi,2);

%% Define parameters
max_a = -Inf;
max_val = -Inf;
lambda = 2.0;
Phi_original = Phi;
% Phi = sparse(Phi_original);

tic
num_routes = int64(num_routes); % each entry is associated with one origin
cum_nroutes = int64([0; cumsum(double(num_routes))]);

%% L1 constraint matrix
L1 = zeros(length(num_routes),n);
for j=1:length(num_routes)
    from = cum_nroutes(j) + 1;
    to = cum_nroutes(j + 1);
    L1(j,from:to) = ones(1,to-from+1);
end

%% cvx
i = 1;
for i=1:n
    cvx_begin quiet
        variable a(n)
        maximize(a(i))
        subject to
        a >= 0
        L1 * a == ones(length(num_routes),1)
        Phi * a == f
    cvx_end
    fprintf('%d/%d\n', i, n)
    if cvx_optval > max_val
        max_val = cvx_optval;
        max_a = a;
    end
end

toc
