%% Raw objective (no regularization)
function a = cvx_raw(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon;

    cvx_begin quiet
        variable a(n)
        if ~noise
            minimize 0
        else
            minimize(square_pos(norm(Phi * a - f, 2)))
        end
        subject to
        if ~noise
            square_pos(norm(Phi * a - f, 2)) <= epsilon
        end
        a >= 0
        L1 * a == ones(length(block_sizes),1)
    cvx_end

end
