function [averaged_m, stddev_m] = average_metrics(ms)
    averaged_m = TestMetrics();
    averaged_m.test_output = TestOutput();
    averaged_m.test_output.test_parameters = TestParameters();
    
    averaged_m.test_output.test_parameters.Phi = 0;
    averaged_m.test_output.runtime = mean(cellfun(@(x) x.test_output.runtime, ms));
    averaged_m.error_L1 = mean(cellfun(@(x) x.error_L1, ms));
    averaged_m.error_L2 = mean(cellfun(@(x) x.error_L2, ms)); 
    averaged_m.error_support = mean(cellfun(@(x) x.error_support, ms));
    averaged_m.error_max_support = mean(cellfun(@(x) x.error_max_support, ms));
    averaged_m.real_sparsity = mean(cellfun(@(x) x.real_sparsity, ms));
    averaged_m.test_sparsity = mean(cellfun(@(x) x.test_sparsity, ms));
    for m = ms
        m = m{:};
        averaged_m.test_output.test_parameters.Phi = m.test_output.test_parameters.Phi; % Not averaged
    end
    
    stddev_m = TestMetrics();
    stddev_m.test_output = TestOutput();
    stddev_m.test_output.test_parameters = TestParameters();
    
    stddev_m.test_output.runtime = std(cellfun(@(x) x.test_output.runtime, ms));
    stddev_m.error_L1 = std(cellfun(@(x) x.error_L1, ms));
    stddev_m.error_L2 = std(cellfun(@(x) x.error_L2, ms)); 
    stddev_m.error_support = std(cellfun(@(x) x.error_support, ms));
    stddev_m.real_sparsity = std(cellfun(@(x) x.real_sparsity, ms));
    stddev_m.test_sparsity = std(cellfun(@(x) x.test_sparsity, ms));
end
