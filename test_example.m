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

input.parse(varargin{:});

generate_problems_p = input.Results.generate_problems;
generate_output_p = input.Results.generate_output;
generate_metrics_p = input.Results.generate_metrics;

parameters;

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
    
    options = {[4 3 10], [4 3 5]}; % The problems that will be generated
    generate_problem(options);
end

if(generate_output_p)
    % load the problems from the directory
    files = dir(fullfile(param_directory, '*.mat'));
    for file = files'
        numsamples = 1;
        data = load(fullfile(param_directory, file.name));
        output_list = generate_output(data.p, tests);
        % display(output_list);
        numsamples = save_test_outputs(output_directory, output_list, numsamples);
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

%%
% Then to view the results test-by-test, select the test number, e.g.
% errors(2)
% comparison = comparisons(2);
% comparison{1}

end
