function [error_L1 error_L2 comparison] = get_error(i,test_name,time,...
    a,real_a,p)

    lambda = p.lambda; noise = p.noise;
    
    error_L1 = norm(real_a - a,1);
    error_L2 = norm(real_a - a,2);
    comparison = [real_a a];
    if noise
        fprintf('(%d) [%g sec] Test: %s\nlambda: %g,\t error(L1): %g,\t error(L2): %g\n', ...
            i, time, test_name, lambda, error_L1, error_L2)
    else
        fprintf('(%d) [%g sec] Test: %s\nerror(L1): %g,\t error(L2): %g\n', ...
            i, time, test_name, error_L1, error_L2)
    end
end