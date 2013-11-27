% The parameters for the file system structure, etc.

user = getenv('USER');
if strcmp(user,'cathywu') == 1
    python = '/opt/local/bin/python';
    raw_directory = './data/raw/';
    param_directory = './data/params/';
    output_directory = './data/output/';
    metrics_directory = './data/metrics/';
    graphs_directory = './data/graphs/';
elseif strcmp(user,'richard') == 1
    python = 'python';
    raw_directory = './data/raw/';
    param_directory = './data/params/';
    output_directory = './data/output/';
    metrics_directory = './data/metrics/';
    graphs_directory = './data/graphs/';
else
    python = 'LD_LIBRARY_PATH= python';
    base_directory = '~/Dropbox/traffic/data/';
    % base_directory = '~/convex-project/data/';
    raw_directory = [base_directory, 'raw/'];
    param_directory = [base_directory, 'params/'];
    output_directory = [base_directory, 'output/'];
    metrics_directory = [base_directory, 'metrics/'];
    graphs_directory = [base_directory, 'graphs/'];
end