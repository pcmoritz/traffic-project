% Contains parameters for a particular matrix configuration
classdef TestParameters < handle
   properties (Access = public)
      Phi
      f
      n
      w
      num_routes
      L1
      noise
      lambda
      epsilon
      blocks
      real_a

      model_type % string
      type % 'random' or 'traffic'
      
      % shared by both 'random' and 'traffic'
      sparsity
      
      % for 'random'
      rows
      cols
      nroutes
      
      % for 'traffic'
      num_blocks
      num_variables_per_block
      num_nonzeros
      num_constraints
   end
   methods
   end
end