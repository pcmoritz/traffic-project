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
% what_to_generate = containers.Map({'cvx_L2', 'cvx_raw', 'cvx_weighted_L1'}, ...
%     {options, options, options});

% files written to disk: contains TestOutput

function generate_problem(what_to_generate)
%GENERATE_OUTPUT Convert python data files into "raw" algorithm input
% This function writes

methods = {'O', 'OD', 'random'};

date = datestr(now, 30);

numsamples = 1;

user = getenv('USER');
if strcmp(user,'cathywu') == 1
    python = '/opt/local/bin/python';
else
    python = 'LD_LIBRARY_PATH= python';
end

for algorithm = what_to_generate.keys
    for option = what_to_generate(char(algorithm))
        vec = option{1};
        rows = vec(1);
        cols = vec(2);
        k = vec(3);
        directory = '~/Dropbox/traffic/data/raw/';
        algorithm = char(algorithm);
        subdir = char(strcat(num2str(rows), '_', num2str(cols), ...
            '_', num2str(k), '_', num2str(date), '_', num2str(numsamples)));
        
        command = sprintf('%s static_matrix.py --prefix %s/%s%s_ --num_rows %d --num_cols %d --num_routes_per_od %d', python, ...
            directory, algorithm, subdir, rows, cols, k);
        numsamples = numsamples + 1;
        fprintf('Generating "raw" for %s %s\n', algorithm, subdir);
        system(command);
        
        directory = '~/Dropbox/traffic/data/problems/';
        fprintf('Generating "problem" for %s %s\n', algorithm, subdir);
        
        for method = methods
            create_dir(char(strcat(directory, method)));
        end
    end
end

end

function create_dir(directory)
if ~exist(directory, 'dir')
  mkdir(directory);
end
end
