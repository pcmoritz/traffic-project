%% cvx multiple-block L_infty
%% Has exponential complexity, so can take a very long time!
function min_a = cvx_mult_blocks_L_infty(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; num_routes = p.num_routes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;

    len_num_routes = length(num_routes);
    
    min_a = Inf;
    min_val = Inf;
    fprintf(1,'Progress (of %d):  ', prod(num_routes));
    
    k = 1;
    i = ones(len_num_routes, 1);
    all_ones = ones(len_num_routes, 1);
    while true
        for ii=1:len_num_routes
            i(ii) = i(ii) + 1;
            if i(ii) > num_routes(ii)
                i(ii) = 1;
            else
                break;
            end
        end
        
        if i == all_ones
            break
        end
        
        cvx_begin quiet
            variable a(n)
            variable t(len_num_routes)
            if ~noise
                minimize( sum(t) )
            else
                minimize( square_pos(norm(Phi * a - f, 2)) + lambda * sum(t) )
            end
            subject to
            if ~noise
                square_pos(norm(Phi * a - f, 2)) <= epsilon
            end
            a >= 0
            L1 * a == ones(len_num_routes, 1)
            t >= 0
            if ~noise
                a(i) >= inv_pos(t)
            else
                a(i) >= lambda * inv_pos(t)
            end
        cvx_end
        
        fprintf(1,[repmat('\b',1,ceil(log(k)/log(10))) '%d'],k); % Progress
        k = k + 1;
        
        if cvx_optval < min_val
            min_val = cvx_optval;
            min_a = a;
        end
    end
    fprintf('\n')
end
