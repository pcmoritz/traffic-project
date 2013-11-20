% The parameters for the file system structure, etc.

user = getenv('USER');
if strcmp(user,'cathywu') == 1
    python = '/opt/local/bin/python';
    raw_directory = './data/raw/';
    param_directory = './data/params/';
    output_directory = './data/output/';
    metrics_directory = './data/metrics/';
elseif strcmp(user,'richard') == 1
    python = 'python';
    raw_directory = './data/raw/';
    param_directory = './data/params/';
    output_directory = './data/output/';
    metrics_directory = './data/metrics/';
else
    python = 'LD_LIBRARY_PATH= python';
    raw_directory = '~/Dropbox/traffic/data/raw/';
    param_directory = '~/Dropbox/traffic/data/params/';
    output_directory = '~/Dropbox/traffic/data/output/';
    metrics_directory = '~/Dropbox/traffic/data/metrics/';
end