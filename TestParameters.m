% Contains parameters for a particular matrix configuration
classdef TestParameters < handle
   properties (Access = public)
      Phi
      f
      n
      w
      L1
      noise
      lambda
      epsilon
      blocks
      real_a

      model_type % string
      type % 'random' or 'traffic'
      
      block_sizes; % vector of the sizes of the blocks in alpha/a.
                   % the length of this is the number of blocks.
      sparsity     % fraction of non-zero entries in alpha/a.
      
      % for 'traffic'
      rows         % number of rows in the traffic grid
      cols         % number of cols in the traffic grid
      nroutes      % number of non-zero routes between each OD pair
      
      % for 'random'
      num_nonzeros % total number of nonzeros in alpha/a.
   end
   methods
   end
end