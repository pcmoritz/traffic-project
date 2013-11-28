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

% options = [4 3 10; 4 3 5];

% files written to disk: contains TestOutput

% options for random matrix is a list of 4-tuples of the form
% [rows, cols, num_blocks, num_vars_per_block]

% type is 'traffic' or 'random'

function generate_problem(type, options)
%GENERATE_OUTPUT Convert python data files into "raw" algorithm input

models = {'small_graph_random', 'small_graph_OD', 'small_graph'};

date = datestr(now, 30);

parameters % load parameters (python executable, names of directories, etc)

numsamples = 1;

for option = options'
    vec = option;
    

    subdir = char(strcat(num2str(vec(1)), '_', num2str(vec(2)), ...
        '_', num2str(vec(3)), '_', num2str(vec(4)), '_', num2str(date), '_', num2str(numsamples)));
    
    if strcmp(type, 'traffic')
        rows = vec(1);
        cols = vec(2);
        k = vec(3);
        d = vec(4);
        
        command = sprintf('%s static_matrix.py --prefix %s%s_ --num_rows %d --num_cols %d --num_routes_per_od %d --num_nonzero_routes_per_o %d', python, ...
        raw_directory, subdir, rows, cols, k, d);
    
        numsamples = numsamples + 1;
        fprintf('Generating "raw" for %s\n', subdir);
        system(command);

        fprintf('Generating "parameters" for %s\n', subdir);
        for model=models
            filename = sprintf('%s%s_%s',raw_directory,subdir,model{1});
            p = TestParameters();
            p.rows = rows; p.cols = cols; p.nroutes = k;
            p.model_type = model{1};
            model_to_testparameters(p,filename);
            p.sparsity = sum(abs(p.real_a)>1e-6)/length(p.real_a);
            save(sprintf('%s/%s-%s-%d',param_directory,datestr(now, 30),getenv('USER'), numsamples),'p');
        end
    end
    
    if strcmp(type, 'random')
        num_constraints = vec(1);
        num_blocks = vec(2);
        num_vars_per_block = vec(3);
        num_nonzeros = vec(4);
        
        command = sprintf('%s random_matrix.py --prefix %s%s_ --num_constraints %d --num_blocks %d --num_vars_per_block %d --num_nonzeros %d', python, ...
            raw_directory, subdir, num_constraints, num_blocks, num_vars_per_block, num_nonzeros);
        
        numsamples = numsamples + 1;
        fprintf('Generating "raw" for %s\n', subdir);
        system(command);

        fprintf('Generating "parameters" for %s\n', subdir);
        
        model = 'random_matrix';
        
        filename = sprintf('%s%s_%s',raw_directory,subdir,model);
        p = TestParameters();
            
        p.block_sizes = num_vars_per_block * ones(num_blocks);
        p.num_nonzeros = num_nonzeros;
          
        p.type = 'random';
        p.model_type = 'gaussian';
        model_to_testparameters(p,filename);
        p.sparsity = sum(abs(p.real_a)>1e-6)/length(p.real_a);
        save(sprintf('%s/%s-%s-%d',param_directory,datestr(now, 30),getenv('USER'), numsamples),'p');
    end
end

end

function create_dir(directory)
if ~exist(directory, 'dir')
  mkdir(directory);
end
end
