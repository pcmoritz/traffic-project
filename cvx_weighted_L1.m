%% Weighted L_1
function a = cvx_weighted_L1(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda; w = p.w;

    cvx_begin quiet
        variable a(n)
        if ~noise
            minimize( sum(w' * abs(a)) )
        else
            minimize( square_pos(norm(Phi * a - f, 2))+ ...
                lambda * sum(mu' * abs(a)) )
        end
        subject to
        if ~noise
            square_pos(norm(Phi * a - f, 2)) <= epsilon
        end
        a >= 0
        L1 * a == ones(length(block_sizes),1)
    cvx_end

end
