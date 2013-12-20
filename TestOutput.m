% Contains parameters for a particular test setup
% Usage would be something like:
%   load 'test_parameters'
%   o = TestOutput();
%   o.test_parameters = test_parameters;
%   o.algorithm = 'cvx_single_block_L_infty'
%   o.tester = getenv('USER');
classdef TestOutput < handle
   properties (Access = public)
       test_parameters % Object

       algorithm % string

       runtime % float
       a % alpha vector
       tester % username of user running test (for renormalization of runtime)
   end

   methods (Access = public)
   function same=equals(obj, o)
       same = (obj.test_parameters.equals(o.test_parameters)) && ...
           (strcmp(obj.algorithm, o.algorithm));
   end
   function o=isAmong(obj, os)
       for o = os
           if obj.equals(o{1})
               o = o{1};
               return
           end
       end
       o=false;
   end
   end
end