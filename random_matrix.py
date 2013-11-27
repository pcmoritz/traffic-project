import argparse
import itertools
import matplotlib
import numpy
import scipy.io
import random

def export_matrices(prefix, num_blocks, num_vars_per_block, num_nonzeros, num_constraints):
    num_vars = num_blocks * num_vars_per_block
    matrix = numpy.random.randn(num_constraints, num_vars)
    alpha = generate_alpha(num_blocks, num_vars_per_block, num_nonzeros)
    f = numpy.dot(matrix, alpha)
    scipy.io.savemat(prefix + 'random_matrix.mat', 
                     {'phi': matrix, 'real_a': alpha,
                      'f': f, 'num_blocks' : num_blocks}, oned_as='column')

def generate_alpha(num_blocks, num_vars_per_block, num_nonzeros):
    # first determine the entries that will be nonzero (by cycling through the blocks and turn by turn filling up the array nonzero_indices)
    nonzero_indices = [set() for i in xrange(num_blocks)]
    for j in itertools.islice(itertools.cycle(range(num_blocks)), num_nonzeros):
        which_indices_to_choose_from = set(range(num_vars_per_block)) - nonzero_indices[j]
        nonzero_indices[j].add(random.sample(which_indices_to_choose_from, 1)[0])

    # now populate these nonzero entries with a Dirichlet draw.    
    result = numpy.zeros(num_blocks * num_vars_per_block)
    for j in range(num_blocks):
      block = result[j * num_vars_per_block:(j+1) * num_vars_per_block]
      block[list(nonzero_indices[j])] = numpy.random.dirichlet([1] * len(nonzero_indices[j]))
    return result

if __name__ == '__main__':
    import sys
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix', type=str, required=True, help="Prefix where to export files to")
    parser.add_argument('--num_blocks', type=int, required=True, help="Number of blocks in the unknown vector")
    parser.add_argument('--num_vars_per_block', type=int, required=True, help="Number of variables per block")
    parser.add_argument('--num_nonzeros', type=int, required=True,
                        help="Total number of nonzeros in the unknown vector. Must be greater or equal to the number of blocks.")
    parser.add_argument('--num_constraints', type=int, required=True, help="Number of constraints")
    args = parser.parse_args()
    
    if args.num_nonzeros < args.num_blocks:
      exit('Number of nonzeros ({}) is less than the number of blocks ({}).'.format(args.num_nonzeros, args.num_blocks))
    export_matrices(args.prefix, args.num_blocks, args.num_vars_per_block, args.num_nonzeros, args.num_constraints)
