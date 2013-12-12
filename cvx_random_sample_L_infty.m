%% cvx multiple-blocks L_infty with random sampling
function min_a = cvx_random_sample_L_infty(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    cum_nroutes = int64([0; cumsum(double(block_sizes))]);
    len_block_sizes = length(block_sizes);
    
    num_iterations = 100;
    fprintf(1, 'Progress (of %d):  ', num_iterations);
    
    min_a = Inf;
    min_val = Inf;
    
    a = zeros(n, 1);
    for j=1:length(block_sizes)
        from = cum_nroutes(j) + 1;
        to = cum_nroutes(j + 1);
        a(from:to) = ones(to - from + 1, 1) / double(to - from + 1);
    end

    %% Sampling prior via unconstrained L1 and L2 solutions
    % Find a feasible solution
    a_L1 = cvx_unconstrained_L1(p);
    a_L2 = cvx_L2(p);
    a_raw = cvx_raw(p);
    a0 = a_L1 + a_L2 + 0.1;

    %% Random sampling
    for k=1:num_iterations
        i = zeros(len_block_sizes, 1);

        % Sample
        for j=1:len_block_sizes
            from = cum_nroutes(j) + 1;
            to = cum_nroutes(j + 1);
            % ~ is max, i(j) is argmax
            % mnrnd(1, ...) returns a vector with one 1 and the rest 0.
            [~, i(j)] = max(mnrnd(1, a0(from:to) / sum(a0(from:to))));
        end
        i = int64(i) + int64(cum_nroutes(1:end-1));
        
        % Try sample
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
        
        % DEBUG
%         if mod(k,100) == 0
%             [p.real_a a_raw a_L1 a_L2 a0 min_a]
%             [norm(p.real_a - a_L1,1) norm(p.real_a - a_raw,1) norm(p.real_a - a_L2,1) norm(p.real_a - a0,1) norm(p.real_a - min_a,1)]
%         end
    end
    fprintf(1, '\n');
    [norm(p.real_a - a_L1,1) norm(p.real_a - a_raw,1) norm(p.real_a - a_L2,1) norm(p.real_a - min_a,1)]
end
