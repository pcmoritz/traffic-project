%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
% load('small_graph.mat')
load('augmented_graph.mat')
Phi = phi;
real_a = alpha;
m = size(Phi,1);
n = size(Phi,2);

%% Define parameters
min_a = Inf;
min_val = Inf;
lambda = 0.1;
Phi_original = Phi;
% Phi = sparse(Phi_original);

tic
% nroutes = [1,2,5,3];
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
    cvx_begin quiet
        variable a(n)
        minimize( square_pos(norm(Phi * a - f, 2)) + lambda * sum(mu' * abs(a)) )
        subject to
        a >= 0
        % L1 * a == ones(length(num_routes),1)
    cvx_end

toc
