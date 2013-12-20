function avg_test_mu = cross_validation(n,k)
    cvx_solver mosek;
    
    no_constraints = 150; % 150-230 (180)
    no_blocks = 10;
    no_vars_per_block = 100;
    sparsity = 0.06;
    no_nonzeros = max(no_blocks, floor(no_blocks * no_vars_per_block * sparsity));
    matrix_sizes = [no_constraints no_blocks no_vars_per_block no_nonzeros];
                
    params = cell(1);
    for i=1:n
        p = generate_problem('random', matrix_sizes);
        params{end+1} = p;
    end
    params(1) = [];
    
    mus = [0 10.^linspace(-10,2,20)];
    % Requires bioinformatics toolbox
    % Indices = crossvalind('Kfold', n, k);
    Indices = ones(n,1);
    temp = randperm(n,n);
    for i=1:k-1
        Indices(temp>i*k & temp<=(i+1)*k) = i+1;
    end
    
    test_util = [];
    test_mu = [];
    
    % k-fold cross validation
    for q=1:k
        max_util = 0;
        max_mu = Inf;

        % Train
        for j=1:length(mus)
            mu = mus(j);
            train = params(Indices~=q);
            util = 0;
            L1_err = 0;
            for p=train
                p = p{1};
                a = cvx_elastic_net(p,mu);
                util = util + get_max_support_utility(p,a);
                L1_err = L1_err + norm(p.real_a-a,1);
            end
            if util > max_util
                max_util = util;
                max_mu = mu;
            end
            fprintf('mu: %e, util: %e, L1_err: %7.2f\n', mu, util, L1_err);
        end
        fprintf('max_mu: %e\n', max_mu);

        % Test
        test = params(Indices==q);
        util = 0;
        for p=test
            p = p{1};
            a = cvx_elastic_net(p,max_mu);
            util = util + get_max_support_utility(p,a);
        end
        test_util = [test_util util]
        test_mu = [test_mu max_mu]
    end
    avg_test_mu = mean(test_mu);
end