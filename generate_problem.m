% the directory structure is the following one:
% first level: problems
% second level: all the files that contain the input for the algorithm
% names of the files: size_numberofroutes_sparsity_timestamp_samplenumber.mat
% example: 4_3_5_0.01_20131112T215817_1
% each file contains the problem description for the algorithm (Cathy's
% datastructure)

% the object what_to_generate contains the following information:
% options is a list of triple of [rows cols k] (these will be generated)
% what_to_generate maps algorithms to options

% options = {[4 3 10], [4 3 5]};

% files written to disk: contains TestOutput

function generate_problem(options)
%GENERATE_OUTPUT Convert python data files into "raw" algorithm input

methods = {'O', 'OD', 'random'};
models = {'small_graph_random', 'small_graph_OD', 'small_graph'};

date = datestr(now, 30);

numsamples = 1;

user = getenv('USER');
if strcmp(user,'cathywu') == 1
    python = '/opt/local/bin/python';
    raw_directory = './data/raw/';
    param_directory = './data/params/';
else
    python = 'LD_LIBRARY_PATH= python';
    raw_directory = '~/Dropbox/traffic/data/raw/';
    param_directory = '~/Dropbox/traffic/data/params/';
end

for option = options
    vec = option{1};
    rows = vec(1);
    cols = vec(2);
    k = vec(3);
    subdir = char(strcat(num2str(rows), '_', num2str(cols), ...
        '_', num2str(k), '_', num2str(date), '_', num2str(numsamples)));

    command = sprintf('%s static_matrix.py --prefix %s%s_ --num_rows %d --num_cols %d --num_routes_per_od %d', python, ...
        raw_directory, subdir, rows, cols, k);
    numsamples = numsamples + 1;
    fprintf('Generating "raw" for %s\n', subdir);
    system(command);

    fprintf('Generating "parameters" for %s\n', subdir);
    for model=models
        filename = sprintf('%s/%s_%s',raw_directory,subdir,model{1});
        p = TestParameters();
        p.rows = rows; p.cols = cols; p.nroutes = k; p.sparsity = 0;
        p.model_type = model{1};
        model_to_testparameters(p,filename);
        save(sprintf('%s/%s-%s',param_directory,datestr(now, 30),getenv('USER')),'p');
        % TODO save p to disk by user-timestamp
    end
    
    for method = methods
        create_dir(char(strcat(param_directory, method)));
    end
end

end

function create_dir(directory)
if ~exist(directory, 'dir')
  mkdir(directory);
end
end
