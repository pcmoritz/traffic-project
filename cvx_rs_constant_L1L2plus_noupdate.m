%% cvx multiple-blocks L_infty with random sampling
function max_a = cvx_rs_constant_L1L2plus_noupdate(p)
    iterations = @(x) 1000;
    prior = @(p) cvx_unconstrained_L1(p) + 0.01;
    update = @(a_old, a_new) a_old;
    [max_a,max_err] = random_sample_alg(p, iterations, prior, update);
    plot(1:iterations(p),max_err);
    save(sprintf('rs_constant_L1L2plus_noupdate-%s.txt',datestr(now, 30)), ...
        'max_err', '-ASCII','-append');
end
