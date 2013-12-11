function filtered_metrics = filter_metrics(type,metrics,mysize,algo,blocks_matter)
    if strcmp(type, 'traffic')
        rows = mysize(1);
        cols = mysize(2);
        nroutes = mysize(3);
        hits = cellfun(@(x) strcmp(x.test_output.test_parameters.type, 'traffic') && ...
            x.test_output.test_parameters.rows == rows && ...
            x.test_output.test_parameters.cols == cols && ...
            x.test_output.test_parameters.nroutes == nroutes && ...
            strcmp(x.test_output.algorithm, algo), metrics);
        filtered_metrics = metrics(hits);
    elseif strcmp(type, 'random')
        m = mysize(1);
        no_blocks = mysize(2);
        no_vars_per_blocks = mysize(3);
        n = mysize(2) * mysize(3);
        if blocks_matter
        hits = cellfun(@(x) strcmp(x.test_output.test_parameters.type, 'random') && ...
            all([size(x.test_output.test_parameters.Phi), x.test_output.test_parameters.block_sizes(1), length(x.test_output.test_parameters.block_sizes)] == [m,n,no_vars_per_blocks,no_blocks]) && ...
            strcmp(x.test_output.algorithm, algo), metrics);
        else
            hits = cellfun(@(x) strcmp(x.test_output.test_parameters.type, 'random') && ...
            all(size(x.test_output.test_parameters.Phi) == [m, n]) && ...
            strcmp(x.test_output.algorithm, algo), metrics);
        end
        filtered_metrics = metrics(hits);
    else
        display('Not implemented.')
    end
end