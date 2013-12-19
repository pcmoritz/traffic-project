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

    obj = @(a) -sum(a .* log(a + 1e-10));
    prev_ent = 0;
    curr_ent = obj(a);
    a_delta = 1;

    num_iterations = 100;
    fprintf(1, 'Progress (of %d):  ', num_iterations);
    
    for k=1:num_iterations
        y = -a .* log(a + epsilon) - a; % Newton's method update
        
        cvx_begin quiet
            variable a_delta(n)
            minimize( y' * a_delta )
            
            subject to % still feasible
            Phi * (a + a_delta) == f
            (a + a_delta) >= 0
            L1 * (a + a_delta) == ones(length(block_sizes), 1)
        cvx_end
        
        obj_a = obj(a);
        magnitude = 1;
        while magnitude > 1e-5
            new_a = a + magnitude * a_delta;
            obj_new_a = obj(new_a);
            if obj_new_a < obj_a
                a = new_a;
                break
            end
            magnitude = magnitude * 0.8;
        end
        if norm(magnitude * a_delta) < 1e-4
            break
        end    
        fprintf(1,[repmat('\b',1,ceil(log(k)/log(10))) '%d'], k); % Progress
    end
    fprintf('\n')
    
    min_a = a;
end
