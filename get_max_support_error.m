% Returns max support error
function err = get_max_support_error(p,a)
    ind = get_max_support(p);
    % Possible error functions include:
    % >> fraction of correct max support
    % err = err + sum(a(ind) > 1e-5)/sum(p.real_a(ind) > 1e-5);
    % >> sum(1 - probability of max entry)
    err = norm(1-a(ind),1);
end