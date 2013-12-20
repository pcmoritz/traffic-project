%% cvx multiple-blocks L_infty with random sampling
function [max_a,max_errs] = random_sample_alg(p, iterations, prior, update)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    cum_nroutes = int64([0; cumsum(double(block_sizes))]);
    len_block_sizes = length(block_sizes);
    
    num_iterations = iterations(p); %10*log(double(len_block_sizes^block_sizes(1)));
    max_errs = zeros(num_iterations, 1);
    fprintf(1, 'Progress (of %d):  ', num_iterations);
    
    %% Sampling prior via unconstrained L1 and L2 solutions
    % Find a feasible solution
    a0 = prior(p);

    %% Hot start
    max_a = -Inf;
    max_val = -Inf;

    % Augment with L1 constraints
    f = [f; ones(size(L1,1),1)];
    Phi = [Phi; L1];

    a = 0;
    m = size(Phi,1);

    code_eq = repmat('EQ', length(f), 1);
    code_bs = repmat('BS', m, 1);
        
    %% Random sampling
    for k=1:num_iterations % number of trials
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
        
        % The program we have to solve here is (in the noiseless case):
        % for variable a in \R^n, maximize a(i),
        % subject to sum(a) = 1, a >= 0, Phi * a == f

        % Set initial condition
        if length(a) > 1 % one iteration is already done
            % Beware: This only works for the primal!
            bas.skc = code_eq;
            bas.skx = code_bs;
            bas.xc = f;
            bas.xx = a;
        end

        c = sparse(n, 1);
        c(i) = 1;

        prob.c = c;
        prob.a = Phi;
        prob.blc = f; % lower bound for constraints
        prob.buc = f; % upper bound for constraints
        prob.blx = sparse(n, 1); % lower bound for variables
        prob.bux = []; % no upper bound for variables

        % param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_PRIMAL_SIMPLEX';
        param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_INTPNT';
        [r, res] = mosekopt('maximize echo(0)', prob, param);
        sol   = res.sol;
        a = sol.bas.xx;
        val = sol.bas.pobjval;

        fprintf(1,[repmat('\b',1,ceil(log(double(k))/log(10))) '%d'],k); % Progress
        if val > max_val
            max_val = val;
            max_a = a;
            a0 = update(a0,a);
            max_err = norm(max_a-p.real_a,1);
        end
        max_errs(k) = max_err;
    end
    fprintf(1, '\n');
    % [ len_block_sizes block_sizes(1) size(Phi,1)-size(L1,1)]
    % [p.num_nonzeros/p.n norm(p.real_a - max_a,1)]

end
