function [error comparison] = get_error(i,test_name,time,a,real_a,p)
    lambda = p.lambda; noise = p.noise;
    
    error = norm(real_a - a,1);
    comparison = [real_a a];
    if noise
        fprintf('(%d) [%g sec] Test: %s\nlambda: %g,\t error: %g\n', i, ...
            time, test_name, lambda, error)
    else
        fprintf('(%d) [%g sec] Test: %s\nerror: %g\n', i, time, ...
            test_name, error)
    end
end