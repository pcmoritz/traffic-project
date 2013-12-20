function filtered_metrics = filter_metrics(type,metrics,mysize,algo,blocks_matter)
    
    if isempty(strfind(char(type), 'small')) == 0  % check if type string includes traffic
        rows = mysize(1);
        cols = mysize(2);
        nroutes = mysize(3);
        hits = cellfun(@(x) strcmp(x.test_output.test_parameters.model_type, type) && ...
            x.test_output.test_parameters.rows == rows && ...
            x.test_output.test_parameters.cols == cols && ...
            x.test_output.test_parameters.nroutes == nroutes && ...
            strcmp(x.test_output.algorithm, algo), metrics);
        filtered_metrics = metrics(hits);
    elseif strcmp(type, 'gaussian')
        m = mysize(1);
        no_blocks = mysize(2);
        no_vars_per_blocks = mysize(3);
        n = mysize(2) * mysize(3);
        if blocks_matter
        hits = cellfun(@(x) strcmp(x.test_output.test_parameters.model_type, 'gaussian') && ...
            all([size(x.test_output.test_parameters.Phi), x.test_output.test_parameters.block_sizes(1), length(x.test_output.test_parameters.block_sizes)] == [m,n,no_vars_per_blocks,no_blocks]) && ...
            strcmp(x.test_output.algorithm, algo), metrics);
        else
            hits = cellfun(@(x) strcmp(x.test_output.test_parameters.model_type, 'gaussian') && ...
            all(size(x.test_output.test_parameters.Phi) == [m, n]) && ...
            strcmp(x.test_output.algorithm, algo), metrics);
        end
        filtered_metrics = metrics(hits);
    else
        display('Not implemented.')
        %filtered_metrics = [];
    end
    assert(length(filtered_metrics) > 0);
end