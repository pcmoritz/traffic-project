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

      type % 'random' or 'traffic'
      model_type % string describing how Phi/f/real_a was generated
                 % (small_graph, small_graph_OD, etc. for 'traffic')
                 % (gaussian, etc. for 'random')
      
      block_sizes; % vector of the sizes of the blocks in real_a.
                   % the length of this is the number of blocks.
      sparsity     % fraction of non-zero entries in real_a.
      
      % for 'traffic'
      rows         % number of rows in the traffic grid
      cols         % number of cols in the traffic grid
      nroutes      % number of non-zero routes between each OD pair
      
      % for 'random'
      num_nonzeros % total number of nonzeros in real_a.
   end
   methods (Access = public)
   function same=equals(obj,p)
       same = isequal(p.Phi,obj.Phi) && isequal(p.f,obj.f) && ...
           eq(p.n,obj.n) && isequal(p.w,obj.w) && ...
           isequal(p.L1,obj.L1) && eq(p.noise,obj.noise) && ...
           isequal(p.lambda,obj.lambda) && eq(p.epsilon,obj.epsilon) && ...
           isequal(p.blocks,obj.blocks) && ...
           isequal(p.real_a,obj.real_a) && strcmp(p.type,obj.type) && ...
           strcmp(p.model_type,obj.model_type) && ...
           isequal(p.block_sizes,obj.block_sizes) && ...
           eq(p.sparsity,obj.sparsity) && ...
           isequal(p.rows,obj.rows) && ...
           isequal(p.cols,obj.cols) && ...
           isequal(p.nroutes,obj.nroutes) && ...
           eq(p.num_nonzeros,obj.num_nonzeros);
   end
   end
end