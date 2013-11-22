function m = output_to_metrics(o)
    p = o.test_parameters;
    real_a = p.real_a;
    a = o.a;
    time = o.runtime;
    algorithm = o.algorithm;

    lambda = p.lambda; noise = p.noise;
    
    error_L1 = norm(real_a - a,1) / norm(real_a, 1);
    error_L2 = norm(real_a - a,2) / norm(real_a, 2);
    error_support = sum((abs(real_a) > 1e-6) ~= (abs(a) > 1e-6)) / length(a);
    real_sparsity = sum(abs(real_a)>1e-6)/length(a);
    test_sparsity = sum(abs(a)>1e-6)/length(a);
    if noise
        fprintf('[%g sec] Alg: %s\nlambda: %g,\t error(L1): %g,\t error(L2): %g,\t error(support): %g,\t sparsity: %g/%g\n', ...
            time, algorithm, lambda, error_L1, error_L2, error_support, test_sparsity, real_sparsity)
    else
        fprintf('[%g sec] Alg: %s\nerror(L1): %g,\t error(L2): %g,\t error(support): %g,\t sparsity: %g/%g\n', ...
            time, algorithm, error_L1, error_L2, error_support, test_sparsity, real_sparsity)
    end
    
    % Store as TestMetrics object
    m = TestMetrics();
    m.test_output = o;
    m.error_L1 = error_L1; m.error_L2 = error_L2; 
    m.error_support = error_support; m.real_sparsity = real_sparsity;
    m.test_sparsity = test_sparsity;
end