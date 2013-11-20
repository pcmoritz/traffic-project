function matsize = get_matsize(matfile)
    load(sprintf('%s.mat',matfile)); % loads phi, f, real_a, num_routes
    matsize = size(phi);
end
