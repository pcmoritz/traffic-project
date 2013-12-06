%% Usage
% Run this to get the appropriate test file:
% python random_matrix.py --prefix 'blah' --num_blocks 2 --num_vars_per_block 10 --num_nonzeros 10 --num_constraints 10

%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
load('blahrandom_matrix.mat')

Phi = sparse(phi);
m = size(Phi,1);
n = size(Phi,2);

%% Define parameters
min_a = Inf;
min_val = Inf;
lambda = 1e-5;
Phi_original = Phi;

tic
num_routes = int64(block_sizes); % each entry is associated with one origin
cum_nroutes = int64([0; cumsum(double(block_sizes))]);

%% L1 constraint matrix
a = zeros(n, 1);
L1 = zeros(length(num_routes),n);
for j=1:length(num_routes)
    from = cum_nroutes(j) + 1;
    to = cum_nroutes(j + 1);
    L1(j,from:to) = ones(1,to-from+1);
    a(from:to) = ones(to - from + 1, 1) / double(to - from + 1);
end

%% Find a feasible solution
 cvx_begin quiet
    variable a(n)
    minimize 0
    
    subject to
    % square_pos(norm(Phi * a - f, 2)) <= 1e-6
    Phi * a == f
    a >= 0
    L1 * a == ones(length(num_routes), 1)
cvx_end

%% Iteratively minimize entropy
num_iterations = 1000;
for k=1:num_iterations
    % y = -a .* log(a + 1e-10) - a;
    y = -log(a + 1e-10)-1;
    
    cvx_begin quiet
        variable a_delta(n)
        minimize( y' * a_delta )
        
        subject to
        % square_pos(norm(Phi * (a + a_delta) - f, 2)) <= 1e-6
        Phi * (a + a_delta) == f
        (a + a_delta) >= 0
        L1 * (a + a_delta) == ones(length(num_routes), 1)
    cvx_end
    a = a + a_delta;
    a(1:num_routes(1))'
    
    % Compute entropy of a
    t = zeros(length(num_routes), 1);
    for j=1:length(num_routes)
        from = cum_nroutes(j) + 1;
        to = cum_nroutes(j + 1); 
        t(j) = -sum(a(from:to) .* log(a(from:to) + 1e-10));
    end
    fprintf('%d/%d: a_delta %f, opt %f, ent %f, err %f\n', k, num_iterations, ...
        sum(abs(a_delta)), cvx_optval, sum(t), norm(real_a - a, 1));
end
toc

error = norm(real_a - a, 1)
comparison = [real_a a];
