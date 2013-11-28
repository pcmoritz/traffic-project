%% cvx minimize entropy
function min_a = cvx_entropy(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    if noise
        error 'This only works in the noiseless case.'
    end
    
    %% Find a feasible solution
    cvx_begin quiet
        variable a(n)
        minimize 0
        
        subject to
        square_pos(norm(Phi * a - f, 2)) <= epsilon
        a >= 0
        L1 * a == ones(length(block_sizes), 1)
    cvx_end

    num_iterations = 200;
    fprintf(1,'Progress (of %d):  ', num_iterations);
    
    for k=1:num_iterations
        y = -a .* log(a + epsilon) - a;
        
        cvx_begin quiet
            variable a_delta(n)
            minimize( y' * a_delta )
            
            subject to
            square_pos(norm(Phi * (a + a_delta) - f, 2)) <= epsilon
            Phi * (a + a_delta) == f
            (a + a_delta) >= 0
            L1 * (a + a_delta) == ones(length(block_sizes), 1)
        cvx_end
        a = a + a_delta;
        fprintf(1,[repmat('\b',1,ceil(log(k)/log(10))) '%d'], k); % Progress
    end
    fprintf('\n')
    
    min_a = a;
end
