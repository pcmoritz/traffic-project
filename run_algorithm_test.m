%% cvx code for sparse recovery of on small graphs
function run_algorithm_test(o)
cvx_solver mosek;

%% Test parameters object
p = o.test_parameters;
test_mode = o.algorithm;

%% Run optimization methods
if p.noise
    % Noisy case
    for j=1:length(lambdas)
        lambda = lambdas(j);
        p.lambda = lambda;

        test_fn = str2func(test_mode);
        tic
        a = test_fn(p);
        o.a = a;
        o.runtime = toc;
    end
else
    % Noiseless case
    test_fn = str2func(test_mode);
    tic
    a = test_fn(p);
    o.a = a;
    o.runtime = toc;
end
end