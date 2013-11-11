%% Hot start recovery for L_infinity with one block

% call with
% [errors comparisons] = small_sparse_recovery({'cvx_hot_start_lp'},'small_graph')

% execute
% addpath '~/mosek/7/toolbox/r2009b'

function result = cvx_hot_start_lp(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; num_routes = p.num_routes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;

    max_a = -Inf;
    max_val = -Inf;
    fprintf(1,'Progress (of %d):  ', n);
    
    a = 0;
    
    [m n] = size(L1);
    
    % augment with the right 'sum to one constraint'
    Phi = [Phi; L1];
    f = [f; ones(m, 1)];
    
    [m n] = size(Phi);
    
    code_eq = repmat('EQ', length(f), 1);
    code_bs = repmat('BS', m, 1);
    
    for i=1:n
        
        % The program we have to solve here is (in the noiseless case):
        % for variable a in \R^n, maximize a(i),
        % subject to sum(a) = 1, a >= 0, Phi * a == f
        
        if length(a) > 1 % one iteration is already done
            % Beware: This only works for the primal!
            bas.skc = code_eq;
            bas.skx = code_bs;
            bas.xc = f;
            bas.xx = a;
        end
        
        c = sparse(n, 1);
        c(i) = 1;
        
        prob.a = Phi;
        prob.blc = f;
        prob.buc = f;
        prob.blx = sparse(n, 1);
        prob.bux = [];
        
        param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_PRIMAL_SIMPLEX';
        % param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_INTPNT';
        [r, res] = mosekopt('maximize echo(0)', prob, param);
        sol   = res.sol;
        a = sol.bas.xx;
        val = sol.bas.pobjval;
        
        fprintf(1,[repmat('\b',1,ceil(log(i)/log(10))) '%d'],i); % Progress
        if val > max_val
            max_val = val;
            max_a = a;
        end
    end
    result = max_a;
    fprintf('\n')

end