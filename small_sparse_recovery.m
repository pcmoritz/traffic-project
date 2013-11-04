%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
% load('small_graph.mat')
load('augmented_graph.mat')
Phi = sparse(phi);
real_a = alpha;
m = size(Phi,1);
n = size(Phi,2);
% n = 200;
% m = 10;

% Phi = [abs(randn(m,n))];
% for j=1:m*n
%     Phi(ceil(rand*m),ceil(rand*n)) = 0;
% end
% f = [abs(randn(m,1))];

%% Define parameters
min_a = Inf;
min_val = Inf;
lambda = 1e-5;
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
i = 1;
for i=1:n
    cvx_begin quiet
        variable a(n)
        variable t
        minimize( square_pos(norm(Phi * a - f, 2))+ t )
        subject to
        a >= 0
        L1 * a == ones(length(num_routes),1)
        t >= 0
        a(i) >= lambda * inv_pos(t)
    cvx_end
    fprintf('%d/%d\n', i, n)
    if cvx_optval < min_val
        min_val = cvx_optval;
        min_a = a;
    end
end

toc
