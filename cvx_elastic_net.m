%% Elastic net
function a = cvx_elastic_net(p, mu_L2)
    Phi = p.Phi; f = p.f; n = p.n; noise = p.noise; epsilon = p.epsilon;
    lambda = p.lambda;

    if ~exist('mu_L1','var')
        mu_L2 = 1;
    end
    mu_L1 = 1;
    
    a_L1 = cvx_unconstrained_L1(p);
    a_L2 = cvx_L2(p);

    cvx_begin quiet
        variable a(n)
        if ~noise
            minimize( mu_L1 * norm(a,2) + mu_L2 * norm(a,2) )
        else
            minimize( square_pos(norm(Phi * a - f, 2)) + ...
                mu_L1 * norm(a,2) + mu_L2 * norm(a,2) )
        end
        subject to
        if ~noise
            square_pos(norm(Phi * a - f, 2)) <= epsilon
        end
        a >= 0
        % no L1 constraints here
    cvx_end
    
    i = get_max_support(p);
    sum([p.real_a(i) a_L1(i) a_L2(i) a_L1(i)+a_L2(i) a(i)] > 1e-5)
    % [p.sparsity norm(p.real_a - a_L1,1) norm(p.real_a - a_raw,1) norm(p.real_a - a_L2,1) norm(p.real_a - a,1)]

end
