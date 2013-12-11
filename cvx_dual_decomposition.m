%% cvx multiple-blocks L_infty with dual decomposition
function min_a = cvx_dual_decomposition(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    cum_nroutes = int64([0; cumsum(double(block_sizes))]);
    from = cum_nroutes(1:end-1) + 1;
    to = cum_nroutes(2:end);
    len_block_sizes = length(block_sizes);
    
    % initial condition
    mu = 1e4 * ones(size(Phi,1),1);
    delta = 1e-3;
    lambda = 1;
    stop = false;
    
    while ~stop
        min_a = zeros(n,1);
        % Solve the r slave programs
        for k=1:len_block_sizes
            min_val = Inf;
            % Solve the n convex programs for each block
            fprintf(1,'Progress (of %d):  ', n);
            for i=1:block_sizes(k)
                cvx_begin quiet
                    variable a(double(block_sizes(k)))
                    variable t
                    minimize( t + mu' * Phi(:,from(k):to(k)) * a)
                    subject to
                    a >= 0
                    sum(a) == 1
                    t >= 0
                    a(i) >= lambda * inv_pos(t)
                cvx_end
                fprintf(1,[repmat('\b',1,ceil(log(double(i))/log(10))) '%d'],i); % Progress
                if cvx_optval < min_val
                    min_val = cvx_optval;
                    min_a(from(k):to(k)) = a;
                end
            end
            fprintf('\n')
        end

        % Solve the master program
        step = delta * (-f + Phi * min_a);
        norm(step,1)
        [p.real_a min_a]
        if norm(step,1) <= 1e-5
            stop = true;
        else
            mu = mu + step;
        end
    end
        
        % DEBUG
%         if mod(k,100) == 0
%             [p.real_a a_raw a_L1 a_L2 a0 min_a]
%             [norm(p.real_a - a_L1,1) norm(p.real_a - a_raw,1) norm(p.real_a - a_L2,1) norm(p.real_a - a0,1) norm(p.real_a - min_a,1)]
%         end
    [norm(p.real_a - a_L1,1) norm(p.real_a - a_raw,1) norm(p.real_a - a_L2,1) norm(p.real_a - a0,1) norm(p.real_a - min_a,1)]
end
