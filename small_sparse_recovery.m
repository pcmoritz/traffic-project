%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Parameters
% test modes: L_infty_cvx, raw, weighted_L1, unconstrained_L1
test_mode = 'weighted_L1';
lambdas = [1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1 10];
% lambdas = [1e-5];

%% Read in graph
load('small_graph.mat')
% load('augmented_graph.mat')
% load('small_graph_OD.mat')

Phi = sparse(phi);
real_a = alpha;
m = size(Phi,1);
n = size(Phi,2);

num_routes = int64(num_routes); % each entry is associated with one origin
cum_nroutes = int64([0; cumsum(double(num_routes))]);

%% L1 constraint matrix
L1 = zeros(length(num_routes),n);
for j=1:length(num_routes)
    from = cum_nroutes(j) + 1;
    to = cum_nroutes(j + 1);
    L1(j,from:to) = ones(1,to-from+1);
end

%% Solve
min_a = Inf;
min_val = Inf;
for j=1:length(lambdas)
    lambda = lambdas(j);

    %% cvx single-block L_infty
    if strcmp(test_mode,'L_infty_cvx')
        tic
        i = 1;
        fprintf(1,'Progress (of %d):  ', n);
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
            fprintf(1,[repmat('\b',1,ceil(log(i)/log(10))) '%d'],i); % Progress
            if cvx_optval < min_val
                min_val = cvx_optval;
                min_a = a;
            end
        end
        fprintf('\n')
        toc
    end

    %% Raw objective (no regularization)
    if strcmp(test_mode,'raw')
        tic
        cvx_begin quiet
            variable a(n)
            variable t
            minimize(square_pos(norm(Phi * a - f, 2)))
            subject to
            a >= 0
            L1 * a == ones(length(num_routes),1)
        cvx_end
        toc
    end

    %% Weighted L_1
    if strcmp(test_mode,'weighted_L1')
        tic
        cvx_begin quiet
            variable a(n)
            minimize( square_pos(norm(Phi * a - f, 2)) + lambda * sum(mu' * abs(a)) )
            subject to
            a >= 0
            L1 * a == ones(length(num_routes),1)
        cvx_end
        toc
    end

    %% Unconstrained L_1
    if strcmp(test_mode,'unconstrained_L1')
        tic
        cvx_begin quiet
            variable a(n)
            minimize( square_pos(norm(Phi * a - f, 2)) + lambda * sum(abs(a)) )
            subject to
            a >= 0
        cvx_end
        toc
    end
    
    %% Block coordinate descent
    % Philipp will add
    
    %% Random sampling
    % Richard will add
    
    %% Distributed dual, master-slave
    % Fanny will add

    %% Metrics
    error = norm(real_a - a,1);
    comparison = [real_a a];
    fprintf('lambda: %g,\t error: %g\n', lambda, error)
end