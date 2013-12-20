% Contains metrics computed from test results (TestOutput) object
% Usage would be something like:
%   load 'test_output' as 'o'
%   m = output_to_metrics(o);
classdef TestMetrics < handle
   properties (Access = public)
       test_output % Object
       
       error_L1 % float
       error_L2 % float
       error_support % float
       error_max_support % float
       real_sparsity % int
       test_sparsity % int
   end
   methods
   end
end