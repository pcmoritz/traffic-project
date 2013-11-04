function [block_a] = solve_block(Phi, a, f, L1, L1rhs, block, lambda)
%SOLVE_BLOCK Solve one block of the optimization problem, with all the
%other values held fixed, block = [start, end]

%% Define parameters
min_block = Inf;
min_val = Inf;

from = block(1); % inclusive in the block to be optimized over
to = block(2); % inclusive in the block to be optimized over

block_len = to - from + 1;
before = a(1:from-1);
after = a(to+1:end);

Phi_before = Phi(:,1:from-1);
Phi_after = Phi(:,to+1:end);
Phi_block = Phi(:,from:to);

val = Phi_before * before + Phi_after * after;

i = 1;
for i=1:block_len
    cvx_begin quiet
        variable A(block_len)
        variable t
        minimize( square_pos(norm(val + Phi_block * A - f, 2)) + t );
        subject to
        A >= 0;
        sum(A) == 1
        t >= 0;
        A(i) >= lambda * inv_pos(t);
    cvx_end
    fprintf('%d/%d\n', i, block_len)
    if cvx_optval < min_val
        min_val = cvx_optval;
        min_block = A;
    end
end

block_a = min_block;

end

