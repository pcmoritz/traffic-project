%% Raw objective (no regularization)
function a = cvx_raw(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; num_routes = p.num_routes;

    cvx_begin quiet
        variable a(n)
        variable t
        minimize(square_pos(norm(Phi * a - f, 2)))
        subject to
        a >= 0
        L1 * a == ones(length(num_routes),1)
    cvx_end

end
