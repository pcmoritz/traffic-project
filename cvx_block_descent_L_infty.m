%% Coordinate block descent for the L_infty regularization

% call with
% [errors comparisons] = small_sparse_recovery({'cvx_block_descent_L_infty'},'small_graph')

function a = cvx_block_descent_L_infty(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    blocks = p.blocks;
    
    a = zeros(n, 1);

    % set up a initial guess that is feasible
    for k = 1:length(blocks)
        block = blocks(k);
        a(block(1)) = 1;
    end
    
    total_iterations = 5;

    for j = [1:total_iterations]
    fprintf('sweep %d/%d , iteration (of %d) ', j, total_iterations, length(blocks));
    for k = [1:length(blocks)]
        fprintf(1,[repmat('\b',1,ceil(log(k)/log(10))) '%d'],k);
        block = blocks(k,:);
        result = solve_block(Phi, a, f, block, 1.0);
        a(block(1):block(2)) = result;
    end
    fprintf('\n');

    end
end

