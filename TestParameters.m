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
      
      rows
      cols
      nroutes
      sparsity
   end
   methods
   end
end