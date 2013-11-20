% Contains parameters for a particular test setup
% Usage would be something like:
%   load 'test_parameters'
%   o = TestOutput();
%   o.test_parameters = test_parameters;
%   o.algorithm = 'cvx_single_block_L_infty'
classdef TestOutput < handle
   properties (Access = public)
       test_parameters % Object

       algorithm % string

       runtime % float
       a % alpha vector
       tester % username of user running test
   end
   methods
   end
end