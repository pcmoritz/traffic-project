import collections
import random

import matplotlib
import networkx as nx
import numpy as np
import scipy.io

import small_graph
import flows

def generate_static_matrix(graph, routes, sensors, flow_portions, flow_from_each_node=1.0):
  # All route indices are with respect to _routes_.
  route_indices_by_origin = collections.defaultdict(list)
  for i, route in enumerate(routes):
    route_indices_by_origin[route[0]].append(i)
    
  f = np.array([(graph[de[0]][de[1]]['flow'] if 'flow' in graph[de[0]][de[1]] else 0) for de in sensors])
  
  alphas = []
  phis = []
  for node in graph.nodes():
    route_indices_from_node = route_indices_by_origin[node]
    edges_in_route = [set(zip(routes[i], routes[i][1:])) for i in route_indices_from_node]
    
    alpha = np.zeros(shape=(len(route_indices_from_node),1))
    phi = np.zeros(shape=(len(sensors), len(route_indices_from_node)))
    for j in xrange(len(route_indices_from_node)):
      alpha[j] = flow_portions[route_indices_from_node[j]]
      for i in xrange(len(sensors)):
        if sensors[i] in edges_in_route[j]:
          phi[i, j] = flow_from_each_node
          
    phis.append(phi)
    alphas.append(alpha)
  return np.hstack(phis), np.concatenate(alphas), f
  
if __name__ == '__main__':
  graph, routes, sensors = small_graph.generate_small_graph()
  flow_portions = flows.annotate_with_flows(graph, routes)
  
  phi, alpha, f = generate_static_matrix(graph, routes, sensors, flow_portions)
  scipy.io.savemat('small_graph.mat', {'phi': phi, 'alpha': alpha, 'f': f}, oned_as='column')