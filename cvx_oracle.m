%% cvx multiple-blocks L_infty with random sampling
function a = cvx_oracle(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    %% Sampling prior via unconstrained L1 and L2 solutions
    % Find a feasible solution
    %a_L1 = cvx_unconstrained_L1(p);
    %a_L2 = cvx_L2(p);
    %a_raw = cvx_raw(p);
    %a0 = a_L1 + a_L2 + 0.1;

    % Augment with L1 constraints
    f = [f; ones(size(L1,1),1)];
    Phi = [Phi; L1];

    a = 0;
    m = size(Phi,1);

    code_eq = repmat('EQ', length(f), 1);
    code_bs = repmat('BS', m, 1);
        
    %% Oracle
    i = get_max_support(p);

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

    %sum([p.real_a(i) a_L1(i) a_L2(i) a_L1(i)+a_L2(i) a(i)] > 0.0001)
    %[p.sparsity norm(p.real_a - a_L1,1) norm(p.real_a - a_raw,1) norm(p.real_a - a_L2,1) norm(p.real_a - a,1)]
end
