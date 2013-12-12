function avg_test_mu = cross_validation(n,k)
    no_constraints = 10;
    no_blocks = 4;
    no_vars_per_block = 12; 
    sparsity = 0.15;
    no_nonzeros = max(no_blocks, floor(no_blocks * no_vars_per_block * sparsity));
    matrix_sizes = [no_constraints no_blocks no_vars_per_block no_nonzeros];
                
    params = cell(1);
    for i=1:n
        p = generate_problem('random', matrix_sizes);
        params{end+1} = p;
    end
    params(1) = [];
    
    mus = [linspace(0,1,11) linspace(10,100,10)];
    Indices = crossvalind('Kfold', n, k);
    
    test_err = [];
    test_mu = [];
    
    % k-fold cross validation
    for q=1:k
        min_err = Inf;
        min_mu = Inf;

        % Train
        for j=1:length(mus)
            mu = mus(j);
            train = params(Indices~=q);
            err = 0;
            for p=train
                p = p{1};
                a = cvx_elastic_net(p,mu);
                ind = get_max_support(p);
                err = err + sum(a(ind) > 1e-5)/sum(p.real_a(ind) > 1e-5);
            end
            if err < min_err
                min_err = err;
                min_mu = mu;
            end
        end

        % Test
        test = params(Indices==q);
        err = 0;
        for p=test
            p = p{1};
            a = cvx_elastic_net(p,min_mu)
            ind = get_max_support(p);
            err = err + sum(a(ind) > 1e-5)/sum(p.real_a(ind) > 1e-5);
        end
        test_err = [test_err err];
        test_mu = [test_mu min_mu];
    end
    avg_test_mu = mean(test_mu);
end