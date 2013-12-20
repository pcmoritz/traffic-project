%% cvx multiple-blocks L_infty with random sampling
function max_a = cvx_random_sampling_L1_30_replace(p)
    iterations = @(x) 30;
    update = @(a_old, a_new) a_new;
    prior = @(p) cvx_unconstrained_L1(p);
    [max_a,max_err] = random_sample_alg(p, iterations, prior, update);
end
