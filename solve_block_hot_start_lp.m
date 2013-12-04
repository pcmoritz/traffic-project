function [block_a] = solve_block(Phi, a, f, block)
%SOLVE_BLOCK Solve one block of the L_infty problem, with all the
%other values held fixed, block = [start, end]

% solve it with hot_start_lp (fast?)

max_a = -Inf;
max_val = -Inf;

from = block(1); % inclusive in the block to be optimized over
to = block(2); % inclusive in the block to be optimized over

block_len = to - from + 1;
before = a(1:from-1);
after = a(to+1:end);

Phi_before = Phi(:,1:from-1);
Phi_after = Phi(:,to+1:end);
Phi_block = Phi(:,from:to);

val = Phi_before * before + Phi_after * after;

f = f - val;

[m n] = size(Phi_block);

% Augment with L1 constraints
L1 = ones(1, block_len);
f = [f; 1.0];
Phi = [Phi_block; L1];

a = 0;

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
        
        prob.c = c;
        prob.a = Phi;
        prob.blc = f; % lower bound for constraints
        prob.buc = f; % upper bound for constraints
        prob.blx = sparse(n, 1); % lower bound for variables
        prob.bux = []; % no upper bound for variables
        
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
    block_a = max_a;
    fprintf('\n')

end