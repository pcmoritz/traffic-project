%% cvx multiple-blocks L_infty with random sampling
function max_a = cvx_rs_constant_L1L2plus_noupdate(p)
    iterations = @(x) 300;
    prior = @(p) cvx_unconstrained_L1(p) + cvx_L2(p) + 0.1;
    update = @(a_old, a_new) a_old; 
    max_a = random_sample_alg(p, iterations, prior, update);
end
