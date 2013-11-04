# generate a matrix that is augmented by the information from which
# nodes people drove to which node

# format of the matrix:
# 1) one row for each directed edge, giving the flow there

# 2) one row for each directed path through a node u, we specify this
# as a node-node-node triple (predecessor-u-descendant)

import collections
import random

import matplotlib
import networkx as nx
import numpy as np
import scipy.io

import small_graph
import flows
import static_matrix

# only generate the augmented matrix, the static matrix has to be appended
def generate_augmented_matrix(graph, routes, sensors, flow_portions, flow_from_each_node=1.0):
    route_indices_by_origin = flows.get_route_indices_by_origin(routes)

    f = []
    where_did_f_come_from = []
    for node in graph.nodes():
        for (p, n) in graph.node[node]['2nd_flow']:
                f.append(graph.node[node]['2nd_flow'][(p, n)][0])
                where_did_f_come_from.append((graph.node[node]['2nd_flow'][(p, n)][1]));
    
    f = np.array(f);

    phis = []

    print ":begin"

    for node in graph.nodes():
        route_indices_from_node = route_indices_by_origin[node]
        edges_in_route = [set(zip(routes[i], routes[i][1:])) for i in route_indices_from_node]
        phi = np.zeros(shape=(len(f), len(route_indices_from_node)))
        for j in xrange(len(route_indices_from_node)):
            for i in xrange(len(f)):
                info = where_did_f_come_from[i]
                if  route_indices_from_node[j] in info:
                    phi[i, j] = flow_from_each_node
        phis.append(phi)

    print ":end"

    print where_did_f_come_from

    return np.hstack(phis), f

if __name__ == '__main__':
  graph, routes, sensors = small_graph.generate_small_graph()
  (flow_portions,_,_) = flows.annotate_with_flows(graph, routes)
  
  phi, alpha, mu, f, num_routes = static_matrix.generate_static_matrix(graph, routes, sensors, flow_portions)

#  print len(routes)

#  print len(f)

  phi2, f2 = generate_augmented_matrix(graph, routes, sensors, flow_portions)
  np.savetxt('phi.txt', phi2)
#  print sum(np.transpose(phi2))
#  print len(f2)
#  print phi2.shape

#  print phi.shape
  
  Phi = np.concatenate((phi, phi2), axis=0)
  F = np.hstack((f, f2))

#  print "::"
  
#  print Phi
#  print F
  
  scipy.io.savemat('augmented_graph.mat', {'phi': Phi, 'alpha': alpha, 'mu': mu, 'f': F, 'num_routes': num_routes}, oned_as='column')

  
    
