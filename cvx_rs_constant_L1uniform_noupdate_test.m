%% cvx multiple-blocks L_infty with random sampling
function max_a = cvx_rs_constant_L1uniform_noupdate_test(p)
    mus = [0 10.^linspace(-3,-.477,10)]
    iterations = @(x) 50;
    update = @(a_old, a_new) a_old;

    test_err = [];
    for mu = mus
        prior = @(p) cvx_unconstrained_L1(p) + mu;
        [max_a,max_err] = random_sample_alg(p, iterations, prior, update);
        test_err = [test_err max_err(end)];
    end
    test_err
end
