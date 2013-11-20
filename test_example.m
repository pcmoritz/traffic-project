% This function takes three parameters:
% each parameter is 0 if flag is not set, 1 otherwise;
% first parameter: shall the problems be generated?
% second parameter: shall the output be generated?
% third parameter: shall the metrics be generated?

function test_example(varargin)

input = inputParser;
input.FunctionName = 'TEST_EXAMPLE';

input.addOptional('generate_problems', 0, @isnumeric);
input.addOptional('generate_output', 0, @isnumeric);
input.addOptional('generate_metrics', 0, @isnumeric);
input.addOptional('generate_plots', 0, @isnumeric);

input.parse(varargin{:});

generate_problems_p = input.Results.generate_problems;
generate_output_p = input.Results.generate_output;
generate_metrics_p = input.Results.generate_metrics;
generate_plots_p = input.Results.generate_plots;

parameters;
library_names;

% rows = 5; cols = 5; k = 2; n = 2;
% command = sprintf(horzcat(['%s static_matrix.py --prefix "" --num_rows %d ', ...
%       '--num_cols %d --num_routes_per_od %d ', ...
%       '--num_nonzero_routes_per_o %d']), python, rows, cols, k, n)
% system(command);

% p = TestParameters();
% p.rows = rows; p.cols = cols; p.nroutes = k; p.sparsity = 0;
% p.model_type = 'small_graph'; % 'small_graph_random', 'small_graph_OD'

% [errors_L1 errors_L2 comparisons] = small_sparse_recovery(p,{'cvx_L2'});

% TODO finish creating p object not via small_sparse_recovery
% TODO save p to disk (O, OD, random, aug)

tests = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1'};

if(generate_problems_p)
    generate_problem(matrix_sizes);
end

if(generate_output_p)
    % load the problems from the directory
    files = dir(fullfile(param_directory, '*.mat'));
    numsamples = 1;

    for file = files'
        data = load(fullfile(param_directory, file.name));
        output_list = generate_output(data.p, tests);
        % display(output_list);
        
        for o = output_list
            filename = sprintf('TestOutput-%s-%s-%d', user, datestr(now, 30), numsamples);
            save(strcat(output_directory, filename), 'o');
            numsamples = numsamples + 1;
        end
    end
end

if(generate_metrics_p)
    numsamples = 1;

    files = dir(fullfile(output_directory, '*.mat'));
    for file = files'
        data = load(fullfile(output_directory, file.name));
        m = output_to_metrics(data.o);
        filename = sprintf('TestMetrics-%s-%s-%d', user, datestr(now, 30), numsamples);
        save(strcat(metrics_directory, filename), 'm');
        numsamples = numsamples + 1;
    end
end

if(generate_plots_p)
    metrics = containers.Map();
    files = dir(fullfile(metrics_directory, '*.mat'));
    for file = files'
        data = load(fullfile(metrics_directory, file.name));
        m = data.m;
        o = data.m.test_output;
        p = data.m.test_output.test_parameters;
        % FIXME
        key = sprintf('%s::%s::%.3f::%d-%d-%d', p.model_type, o.algorithm, double(p.sparsity), int64(p.rows), int64(p.cols), int64(p.nroutes));
        
        if isKey(metrics, key)
            c = metrics(key);
            c{length(c) + 1} = data.m;
            metrics(key) = c;
        else
            metrics(key) = {data.m};
        end
    end
    
    % Average each value in key
    for key = keys(metrics)
        key = key{:};
        metrics_for_key = metrics(key);
        len = length(metrics_for_key);
        
        averaged_m = TestMetrics();
        averaged_m.test_output = TestOutput();
        averaged_m.test_output.test_parameters = TestParameters();
        averaged_m.test_output.test_parameters.Phi = 0;
        averaged_m.test_output.runtime = 0;
        averaged_m.error_L1 = 0;
        averaged_m.error_L2 = 0; 
        averaged_m.error_support = 0;
        averaged_m.test_output.test_parameters.Phi = 0;
        for m = metrics_for_key
            m = m{:};
            averaged_m.test_output.test_parameters.Phi = m.test_output.test_parameters.Phi; % Not averaged
            averaged_m.test_output.runtime = averaged_m.test_output.runtime + (m.test_output.runtime / len);
            averaged_m.error_L1 = averaged_m.error_L1 + (m.error_L1 / len);
            averaged_m.error_L2 = averaged_m.error_L2 + (m.error_L2 / len);
            averaged_m.error_support = averaged_m.error_support + (m.error_support / len);
        end
        metrics(key) = averaged_m;
        fprintf('%s\n', key)
    end
    
    Plotting(metrics)
end

%%
% Then to view the results test-by-test, select the test number, e.g.
% errors(2)
% comparison = comparisons(2);
% comparison{1}

end
