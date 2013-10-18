%% cvx code for sparse recovery of on small graphs
clear all;
% cvx_solver mosek;

%% Read in graph
% load('small-graph.mat','G')
n = 200;
m = 10;

Phi = [abs(randn(m,n))];
for j=1:m*n
    Phi(ceil(rand*m),ceil(rand*n)) = 0;
end
Phi = sparse(Phi);
f = [abs(randn(m,1))];

%% Define parameters
min_a = Inf;
min_val = Inf;
lambda = 1;
Phi_original = Phi;
Phi = sparse(Phi_original);

tic

%% cvx
i = 1;
for i=1:n
    cvx_begin
        variable a(n)
        variable t
        minimize( square_pos(norm(Phi * a - f, 2)) + t )
        subject to
        a >= 0
        a'*ones(n,1) == 1
        t >= 0
        a(i) >= lambda * inv_pos(t)
    cvx_end
    if cvx_optval < min_val
        min_val = cvx_optval;
        min_a = a;
    end
end

toc
