function averaged_m = average_metrics(ms)
    averaged_m = TestMetrics();
    averaged_m.test_output = TestOutput();
    averaged_m.test_output.test_parameters = TestParameters();
    
    averaged_m.test_output.test_parameters.Phi = 0;
    averaged_m.test_output.runtime = mean(cellfun(@(x) x.test_output.runtime, ms));
    averaged_m.error_L1 = mean(cellfun(@(x) x.error_L1, ms));
    averaged_m.error_L2 = mean(cellfun(@(x) x.error_L2, ms)); 
    averaged_m.error_support = mean(cellfun(@(x) x.error_support, ms));
    averaged_m.real_sparsity = mean(cellfun(@(x) x.real_sparsity, ms));
    averaged_m.test_sparsity = mean(cellfun(@(x) x.test_sparsity, ms));
    for m = ms
        m = m{:};
        averaged_m.test_output.test_parameters.Phi = m.test_output.test_parameters.Phi; % Not averaged
    end
end