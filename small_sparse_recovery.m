%% cvx code for sparse recovery of on small graphs
function [errors_L1 errors_L2 comparisons] = small_sparse_recovery(test_modes,in,noise,lambda)
cvx_solver mosek;

%% Generate matrices
% Todo (call python)

%% Default parameters
% test modes: cvx_single_block_L_infty, cvx_L2, cvx_raw,
%               cvx_unconstrained_L1, cvx_weighted_L1
if ~exist('test_modes','var')
    test_modes = {'cvx_single_block_L_infty'};
end
if ~exist('noise','var')
    noise = false; % false, true
end
if ~exist('lambda','var')
    lambdas = [1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1 10];
    % lambdas = [1e-5];
end
epsilon = 1e-9;

%% Read in graph
% inputs: small_graph, small_graph_OD, augmented_graph
if ~exist('in','var')
    in = 'small_graph';
end
load(sprintf('%s.mat',in)); % loads phi, f, real_a, num_routes
Phi = sparse(phi);
num_routes = int64(num_routes); % each entry is associated with one origin
m = size(Phi,1);
n = size(Phi,2);

%% L1 constraint matrix
L1 = zeros(length(num_routes),n);
cum_nroutes = int64([0; cumsum(double(num_routes))]);
% array with start and stop indices of the blocks:
blocks = zeros(length(num_routes), 2);
for j=1:length(num_routes)
    from = cum_nroutes(j) + 1;
    to = cum_nroutes(j + 1);
    L1(j,from:to) = ones(1,to-from+1);
    blocks(j, :) = [from, to];
end

%% Test parameters object
p = TestParameters();
p.Phi = Phi; p.f = f; p.w = w; p.num_routes = num_routes;
p.n = n; p.L1 = L1; p.noise = noise; p.epsilon = epsilon;
p.blocks = blocks;

%% Run optimization methods
i = 1;
errors_L1 = {};
errors_L2 = {};
comparisons = {};
if noise
    % Noisy case
    for j=1:length(lambdas)
        lambda = lambdas(j);
        p.lambda = lambda;

        for test = test_modes
            test_fn = str2func(test{1});
            tic
            a = test_fn(p);
            [error_L1 error_L2 comparison] = get_error(i,test{1},toc,a,real_a,p);
            errors_L1{i} = error_L1; errors_L2{i} = error_L2;
            comparisons{i} = comparison;
            i = i + 1;
        end
    end
else
    % Noiseless case
    for test = test_modes
        test_fn = str2func(test{1});
        tic
        a = test_fn(p);
        [error_L1 error_L2 comparison] = get_error(i,test{1},toc,a,real_a,p);
        errors_L1{i} = error_L1; errors_L2{i} = error_L2;
        comparisons{i} = comparison;
        i = i + 1;
    end
end
end