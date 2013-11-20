function [mu,s,I] = mutual_coherence(A,nrm)
% function [mu,s,I] = mutual_coherence(A,nrm)
% =========================================================================
%  FILE:           mutual_coherence.m
%  AUTHOR:         Andreas M. Tillmann, TU Braunschweig, Germany
% =========================================================================
%  DESCRIPTION:    Calculates the 'mutual coherence' mu(A) of a Matrix A.
%                  The mutual coherence gives a guarantee of solution 
%                  support size ensuring equivalence of l0- and l1-norm-
%                  minimization over A*x=b, i. e.,
%                  argmin ||x||_0 s.t. A*x=b  == argmin ||x||_1 s.t. A*x=b
%                           (P0)                          (P1)
%
%  INPUT:   A      An (m x n)-matrix with full row-rank (rank(A)=m)
%           nrm    Pass nrm=1, if all columns of A are normalized to unit
%                  Euclidean length
%                  [ optional; default is nrm = 0 ]
%
%  OUTPUT:  mu     The mutual coherence of A, i.e.,
%                  mu(A) = max |A(:,i)'*A(:,j)| / ( ||A(:,i)||*||(A:,j)|| )
%                          (over i,j in {1,...,n}, i not equal to j)
%           s      Support size <= s:=ceil((1/2)*(1+1/mu))-1 ensures 
%                  l0-l1-equivalence, i.e., if Ax=b has a solution x with 
%                  ||x||_0 <= s, then x is the unique solution of both 
%                  (P0) and (P1).
%           I 	   I=[i j], where i and j are the indices of columns of A 
%                  defining mu
% =========================================================================
% $Revision: 451 $
% $Author: andtillm $
% $Date: 2012-01-09 14:06:44 +0100 (Mo, 09. Jan 2012) $
% =========================================================================
if(nargin < 2)
    nrm = 0;
end
n  = size(A,2);
mu = 0;
if( nrm )
    if( issparse(A) )
        for i=1:n        
            for j=(i+1):n % do not compare inn. prod. of a col. with itself
                u = intersect(find(A(:,i)),find(A(:,j)));
                val = abs(A(u,i)'*A(u,j));
                if( mu < val )
                    mu = val;
                    I =  [i j];
                end       
            end
        end
    else
        for i=1:n        
            for j=(i+1):n % do not compare inn. prod. of a col. with itself
                val = abs(A(:,i)'*A(:,j));
                if( mu < val )
                    mu = val;
                    I =  [i j];
                end       
            end
        end
    end
else
    Anorms = zeros(n,1);
    if( issparse(A) )
        Anorms(1) = norm(A(:,1),2);
        for i=1:n
            for j=(i+1):n % do not compare inn. prod. of a col. with itself                
                fprintf('i = %5d, j = %5d\n',i,j);
                u = intersect(find(A(:,i)),find(A(:,j)));
                if( i == 1 ) % compute column norms only once
                    Anorms(j) = norm(A(:,j),2);
                end
                val = abs(A(u,i)'*A(u,j))/(Anorms(i)*Anorms(j));
                if( mu < val )
                    mu = val;
                    I =  [i j];
                end       
            end
        end
    else
        Anorms(1) = norm(A(:,1),2);
        for i=1:n            
            for j=(i+1):n % do not compare inn. prod. of a col. with itself
                if( i == 1 ) % compute column norms only once
                    Anorms(j) = norm(A(:,j),2);
                end
                val = abs(A(:,i)'*A(:,j))/(Anorms(i)*Anorms(j));
                if( mu < val )
                    mu = val;
                    I =  [i j];
                end       
            end
        end
    end
end
s = ceil((1/2)*(1+1/mu))-1;
