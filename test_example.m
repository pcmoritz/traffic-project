% This function takes three parameters:
% each parameter is 0 if flag is not set, 1 otherwise;
% first parameter: shall the problems be generated?
% second parameter: shall the output be generated?
% third parameter: shall the metrics be generated?

function filtered_metrics = test_example(varargin)

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

if(generate_problems_p)
    %delete(fullfile(param_directory, '*.mat'));
    disp('Generating problems:')
    generate_problem('traffic', matrix_sizes('traffic'));
    generate_problem('random', matrix_sizes('random'),2);
end

if(generate_output_p)
    disp('Generating outputs:')
    % load already generated outputs
    existing_output_files = dir(fullfile(output_directory, '*.mat'));
    existing_output = cell(0);
    for file = existing_output_files'
        data = load(fullfile(output_directory, file.name));
        existing_output(end+1) = {data.o};
    end

    % load the problems from the directory
    files = dir(fullfile(param_directory, '*.mat'));
    numsamples = 1;

    for file = files'
        data = load(fullfile(param_directory, file.name));
        output_list = generate_output(data.p, tests, existing_output);
        % display(output_list);
        for o = output_list
            filename = sprintf('TestOutput-%s-%s-%d', user, ...
                datestr(now, 30), numsamples);
            save(strcat(output_directory, filename), 'o');
            numsamples = numsamples + 1;
        end
    end
end

if(generate_metrics_p)
    disp('Generating metrics:')
    numsamples = 1;
    delete(fullfile(metrics_directory, '*.mat'));

    files = dir(fullfile(output_directory, '*.mat'));
    for file = files'
        data = load(fullfile(output_directory, file.name));
        m = output_to_metrics(data.o);
        filename = sprintf('TestMetrics-%s-%s-%d', user, ...
            datestr(now, 30), numsamples);
        save(strcat(metrics_directory, filename), 'm');
        numsamples = numsamples + 1;
    end
end

if(generate_plots_p)
    disp('Generating plots:')
    all_metrics = {};
    files = dir(fullfile(metrics_directory, '*.mat'));
    for file = files'
        data = load(fullfile(metrics_directory, file.name));
        all_metrics{length(all_metrics) + 1} = data.m;
    end
    
    % Make a graph directory
    outdir = fullfile(graphs_directory, datestr(now, 30));
    mkdir(outdir);

    % Plot
    filtered_metrics = Plotting(strcat(outdir, '/'), all_metrics)
end
end
