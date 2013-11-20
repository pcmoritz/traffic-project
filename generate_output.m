% This file implements a "tester". It reads in a parametr object and
% generates an output object. p is a TestParameters object and algorithms a
% list of algorithms that will be run on it.

% Example:
% algorithms = {'cvx_L2','cvx_raw','cvx_unconstrained_L1','cvx_weighted_L1'};

% generate_output(p, {'cvx_L2'})

% we return a cell of test output objects, one for each algorithm


function [output_list] = generate_output(p, algorithms) 
    output_list = {};
    for algorithm = algorithms
        o = TestOutput();
        o.test_parameters = p; o.algorithm = algorithm{1}; o.tester = getenv('USER');
        run_algorithm_test(o);
        output_list = {output_list o};
    end
end

