% Returns indices of the max entry of each block in Phi
function i = get_max_support(p)
    Phi = p.Phi; f = p.f; n = p.n; L1 = p.L1; block_sizes = p.block_sizes;
    noise = p.noise; epsilon = p.epsilon; lambda = p.lambda;
    
    cum_nroutes = int64([0; cumsum(double(block_sizes))]);
    len_block_sizes = length(block_sizes);
    
    i = zeros(len_block_sizes, 1);

    % Sample
    for j=1:len_block_sizes
        from = cum_nroutes(j) + 1;
        to = cum_nroutes(j + 1);
        % ~ is max, i(j) is argmax
        % mnrnd(1, ...) returns a vector with one 1 and the rest 0.
        [~, i(j)] = max(p.real_a(from:to) / sum(p.real_a(from:to)));
    end
    i = int64(i) + int64(cum_nroutes(1:end-1));
end