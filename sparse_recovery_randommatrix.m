%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
% load('small_graph.mat')
% Phi = phi;
% real_a = alpha;
% m = size(Phi,1);
% n = size(Phi,2);

% nroutes = [1,2,5,3];
%num_routes = int64(num_routes);
%cum_nroutes = int64([1 cumsum(double(num_routes'))]);


% RANDOM MATRIX
 n = 30;
 m = 30;
 no_routes = 20; 
 
% Generate random binary matrix
Phi = ones(m,n);
 for j=1:m*n
    Phi(ceil(rand*m),ceil(rand*n)) = 0;
 end
 
 % Create fake sparse alpha
alpha = abs(rand(n,1));
alpha(ceil(n*rand(n,1))) = zeros(n,1);
real_alpha = alpha/sum(alpha);
real_a = real_alpha;
f = Phi * real_alpha;
%f = [abs(randn(m,1))];

%% Define parameters
min_a = Inf;
min_val = Inf;
lambda = 0.001;
Phi_original = Phi;
% Phi = sparse(Phi_original);


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
        sum(a)==1;
        t >= 0
        a(i) >= lambda * inv_pos(t)
    cvx_end
    if cvx_optval < min_val
        min_val = cvx_optval;
        min_a = a;
    end
end

toc
