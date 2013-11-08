%% Unconstrained L_1
function a = cvx_unconstrained_L1(p)
    Phi = p.Phi; f = p.f; n = p.n; noise = p.noise; epsilon = p.epsilon;
    lambda = p.lambda;

    cvx_begin quiet
        variable a(n)
        if ~noise
            minimize( sum(abs(a)) )
        else
            minimize( square_pos(norm(Phi * a - f, 2)) + ...
                lambda * sum(abs(a)) )
        end
        subject to
        if ~noise
            square_pos(norm(Phi * a - f, 2)) <= epsilon
        end
        a >= 0
        % no L1 constraints here
    cvx_end

end
