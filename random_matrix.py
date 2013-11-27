import argparse
import matplotlib
import numpy
import scipy.io
import random

def export_matrices(prefix, num_blocks, num_vars_per_block, sparsity, num_constraints):
    num_vars = num_blocks * num_vars_per_block
    matrix = numpy.random.randn(num_constraints, num_vars)
    alpha = generate_alpha(num_blocks, num_vars_per_block, num_vars - sparsity)
    f = numpy.dot(matrix, alpha)
    scipy.io.savemat(prefix + 'random_matrix.mat', 
                     {'phi': matrix, 'real_a': alpha,
                      'f': f, 'num_blocks' : num_blocks}, oned_as='column')

def generate_alpha(num_blocks, num_vars_per_block, num_nonzero):
    nonzero_indices = []
    blocks = [] # blocks of alpha that will be generated
    # first determine the entries that will be nonzero (by cycling through the blocks and turn by turn filling up the array nonzero_indices)
    while(num_nonzero > 0):
        for j in range(0, num_blocks):
            # print sparsity
            num_nonzero = num_nonzero - 1
            block = range(j * num_vars_per_block, (j+1) * num_vars_per_block)
            which_indices_to_chose_from = set(block).difference(nonzero_indices)
            nonzero_indices = nonzero_indices + random.sample(which_indices_to_chose_from, 1)
            if num_nonzero == 0:
                break
    # print nonzero_indices
    # now populate these nonzero entries with a dirichlet draw.
    for j in range(0, num_blocks):
        block = range(j * num_vars_per_block, (j+1) * num_vars_per_block)
        support = list(set(block).difference(nonzero_indices))
        # print support
        vec = numpy.random.randn(len(support), 1)
        new_block = num_vars_per_block * [0]
        for k in range(0, len(vec)):
            new_block[support[k] - num_vars_per_block * j] = float(vec[k])
        blocks = blocks + [new_block]
    return numpy.array(sum(blocks, [])) # this flattens the list 
        
    

if __name__ == '__main__':
    import sys
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix', type=str, help="Prefix where to export files to")
    parser.add_argument('--num_blocks', type=int, help="Number of blocks in the matrix")
    parser.add_argument('--num_vars_per_block', type=int, help="Number of variables per block")
    parser.add_argument('--sparsity', type=int, help="Number of nonzeros. Must be greater or equal to the number of block.")
    parser.add_argument('--num_constraints', type=int, help="Number of constraints")
    args = parser.parse_args()
    export_matrices(args.prefix, args.num_blocks, args.num_vars_per_block, args.sparsity, args.num_constraints)
