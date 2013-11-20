%% cvx code for sparse recovery of on small graphs
function model_to_testparameters(p,filename)

%% Default parameters
% test modes: cvx_single_block_L_infty, cvx_L2, cvx_raw,
%               cvx_unconstrained_L1, cvx_weighted_L1
if ~exist('test_modes','var')
    test_modes = {'cvx_single_block_L_infty'};
end
if ~exist('noise','var')
    noise = false; % false, true
end
epsilon = 1e-9;

%% Read in graph
% inputs: small_graph, small_graph_OD, augmented_graph
load(sprintf('%s.mat',filename)); % loads phi, f, real_a, num_routes
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
p.Phi = Phi; p.f = f; p.w = w; p.num_routes = num_routes;
p.real_a = real_a; p.n = n; p.L1 = L1; p.noise = noise;
p.epsilon = epsilon; p.blocks = blocks;
end