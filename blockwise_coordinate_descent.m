%% blockwise coordinate descent, see the documentation

clear all;
cvx_solver mosek;

%% Read in the graph
load('augmented_graph.mat')
Phi = sparse(phi);
real_a = alpha;
m = size(Phi,1);
n = size(Phi,2);

lambda = 0.1;

tic
num_routes = int64(num_routes); % each entry is associated with one origin
cum_nroutes = int64([0; cumsum(double(num_routes))]);

%% L1 constraint matrix and blocks
L1 = zeros(length(num_routes),n);
blocks = zeros(length(num_routes), 2);
for j=1:length(num_routes)
    from = cum_nroutes(j) + 1;
    to = cum_nroutes(j + 1);
    L1(j,from:to) = ones(1,to-from+1);
    blocks(j, :) = [from, to];
end
L1rhs = ones(length(blocks),1);

a = zeros(n, 1);

% feasible start
for k = 1:length(blocks)
    block = blocks(k);
    a(block(1)) = 1;
end

%% do the coordinate descent thing

total_iterations = 5;

for j = [1:total_iterations]
for k = [1:length(blocks)]
    fprintf('block iteration: %d/%d\n', k, length(blocks));
    block = blocks(k,:);
    result = solve_block(Phi, a, f, L1, L1rhs, block, 1.0);
    a(block(1):block(2)) = result;
end
fprintf('total iterations at %d/%d, error %d', j, total_iterations, ...
    norm(a - real_a, 1));
end

toc