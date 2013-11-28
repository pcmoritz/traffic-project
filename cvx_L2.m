%% L_2 regularization (unique solution)
function a = cvx_L2(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;

    cvx_begin quiet
        variable a(n)
        variable t
        if ~noise
            minimize( norm(a,2) )
        else
            minimize( square_pos(norm(Phi * a - f, 2))+ lambda * norm(a,2) )
        end
        subject to
        if ~noise
            square_pos(norm(Phi * a - f, 2)) <= epsilon
        end
        a >= 0
        L1 * a == ones(length(block_sizes),1)
    cvx_end

end
