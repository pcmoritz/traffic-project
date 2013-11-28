%% cvx multiple-blocks L_infty with random sampling
function min_a = cvx_random_sample_L_infty(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    cum_nroutes = int64([0; cumsum(double(block_sizes))]);
    len_block_sizes = length(block_sizes);
    
    num_iterations = 200;
    fprintf(1, 'Progress (of %d):  ', num_iterations);
    
    min_a = Inf;
    min_val = Inf;  
    
    a = zeros(n, 1);
    for j=1:length(block_sizes)
        from = cum_nroutes(j) + 1;
        to = cum_nroutes(j + 1);
        a(from:to) = ones(to - from + 1, 1) / double(to - from + 1);
    end

    for k=1:num_iterations
        i = zeros(len_block_sizes, 1);
        for j=1:len_block_sizes
            from = cum_nroutes(j) + 1;
            to = cum_nroutes(j + 1);
            % ~ is max, i(j) is argmax
            % mnrnd(1, ...) returns a vector with one 1 and the rest 0.
            [~, i(j)] = max(mnrnd(1, a(from:to) / sum(a(from:to))));
        end
        
        cvx_begin quiet
            variable a(n)
            variable t(len_block_sizes)
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
            L1 * a == ones(len_block_sizes, 1)
            t >= 0
            if ~noise
                a(i) >= inv_pos(t)
            else
                a(i) >= lambda * inv_pos(t)
            end
        cvx_end
        fprintf(1,[repmat('\b',1,ceil(log(k)/log(10))) '%d'],k); % Progress

        if cvx_optval < min_val
            min_val = cvx_optval;
            min_a = a;
        end
    end
    fprintf(1, '\n');
end
