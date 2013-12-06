%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
load('small_graph.mat')
% load('augmented_graph.mat')
% load('small_graph_OD.mat')

Phi = sparse(phi);
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
    y = -a .* log(a + 1e-10) - a;
    
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
    fprintf('%d/%d: a_delta %f, opt %f, ent %f\n', k, num_iterations, sum(abs(a_delta)), cvx_optval, sum(t))
end
toc

error = norm(real_a - min_a, 1) % 38.6043 on small graph, 29.9805 on small graph OD
comparison = [real_a min_a];
