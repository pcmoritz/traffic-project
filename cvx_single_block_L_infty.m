%% cvx single-block L_infty
function min_a = cvx_single_block_L_infty(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;

    min_a = Inf;
    min_val = Inf;
    fprintf(1,'Progress (of %d):  ', n);
    for i=1:n
        cvx_begin quiet
            variable a(n)
            variable t
            if ~noise
                minimize( t )
            else
                minimize( square_pos(norm(Phi * a - f, 2))+ lambda * t )
            end
            subject to
            if ~noise
                square_pos(norm(Phi * a - f, 2)) <= epsilon
            end
            a >= 0
            L1 * a == ones(length(block_sizes),1)
            t >= 0
            a(i) >= lambda * inv_pos(t)
        cvx_end
        fprintf(1,[repmat('\b',1,ceil(log(i)/log(10))) '%d'],i); % Progress
        if cvx_optval < min_val
            min_val = cvx_optval;
            min_a = a;
        end
    end
    fprintf('\n')

end
