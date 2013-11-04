import collections
import random

import matplotlib
import networkx as nx
import numpy as np
import scipy.io

import small_graph
import flows

def generate_static_matrix(graph, routes, sensors, flow_portions,
        flow_from_each_node=1.0):
  # All route indices are with respect to _routes_.
  route_indices_by_origin = flows.get_route_indices_by_origin(routes)
    
  f = np.array([graph[u][v]['flow'] for (u,v) in sensors])
  
  alphas = []
  mus = []
  phis = []
  num_routes = []
  for node in graph.nodes():
    route_indices_from_node = route_indices_by_origin[node]
    edges_in_route = [set(zip(routes[i], routes[i][1:])) for i in \
            route_indices_from_node]
    
    alpha = np.zeros(shape=len(route_indices_from_node))
    mu = np.zeros(shape=len(route_indices_from_node))
    phi = np.zeros(shape=(len(sensors), len(route_indices_from_node)))
    for j in xrange(len(route_indices_from_node)):
      alpha[j] = flow_portions[route_indices_from_node[j]]
      route = routes[route_indices_from_node[j]]
      mu[j] = sum(1./graph[de[0]][de[1]]['weight'] for de in zip(route,
              route[1:]))
      
      for i in xrange(len(sensors)):
        if sensors[i] in edges_in_route[j]:
          phi[i, j] = flow_from_each_node
    
    num_routes.append(len(route_indices_from_node))
    phis.append(phi)
    mus.append(mu)
    alphas.append(alpha)

  return np.hstack(phis), np.concatenate(alphas), np.concatenate(mus), f, \
          np.array(num_routes)

def generate_static_matrix_OD(graph, routes, sensors, flow_portions,
        flow_from_each_node=1.0):
  # All route indices are with respect to _routes_.
  route_indices_by_OD = flows.get_route_indices_by_OD(routes)
    
  # link flow vector
  f = np.array([graph[u][v]['flow'] for (u,v) in sensors])
  
  # initialize
  alphas = []
  mus = []
  phis = []
  num_routes = []

  # build alpha, mu, phi, num_routes (for L1 constraints)
  for origin in graph.nodes():
    for dest in graph.nodes():
      selected_route_indices_by_OD = route_indices_by_OD[origin][dest]
      edges_in_route = [set(zip(routes[i], routes[i][1:])) for i in \
              selected_route_indices_by_OD]
      
      # initialize
      alpha = np.zeros(shape=len(selected_route_indices_by_OD))
      mu = np.zeros(shape=len(selected_route_indices_by_OD))
      phi = np.zeros(shape=(len(sensors), len(selected_route_indices_by_OD)))

      # skip OD blocks that are all 0
      if flow_from_each_node[origin][dest] == 0:
          continue

      # build phi, alpha, mu block by block (1 origin)
      for j in xrange(len(selected_route_indices_by_OD)):
        alpha[j] = flow_portions[selected_route_indices_by_OD[j]]
        route = routes[selected_route_indices_by_OD[j]]
        # TODO what is mu?
        mu[j] = sum(1./graph[u][v]['weight'] for (u,v) in zip(route,
                route[1:]))
        
        for i in xrange(len(sensors)):
          if sensors[i] in edges_in_route[j]:
            phi[i, j] = flow_from_each_node[origin][dest]
      
      num_routes.append(len(selected_route_indices_by_OD))
      phis.append(phi)
      mus.append(mu)
      alphas.append(alpha)

  return np.hstack(phis), np.concatenate(alphas), np.concatenate(mus), f, \
          np.array(num_routes)
  
if __name__ == '__main__':
  # G = (V,E,w)
  graph, routes, sensors = small_graph.generate_small_graph()
  # (O,D),R,alpha
  (flow_portions,flow_portions_OD,flow_OD) = flows.annotate_with_flows(graph, 
          routes)
  
  # static matrix considering origin flows
  phi, alpha, mu, f, num_routes = generate_static_matrix(graph, routes,
          sensors, flow_portions)
  scipy.io.savemat('small_graph.mat', {'phi': phi, 'alpha': alpha, 'mu': mu,
          'f': f, 'num_routes': num_routes}, oned_as='column')
  print phi
  print np.dot(phi, alpha) - f
  print np.linalg.norm(np.dot(phi, alpha) - f,2)

  # static matrix considering origin-destination flows
  phi, alpha, mu, f, num_routes = generate_static_matrix_OD(graph, routes,
          sensors, flow_portions_OD, flow_from_each_node=flow_OD)
  scipy.io.savemat('small_graph_OD.mat', {'phi': phi, 'alpha': alpha, 'mu': mu,
          'f': f, 'num_routes': num_routes}, oned_as='column')
  print phi
  print np.dot(phi, alpha) - f
  print np.linalg.norm(np.dot(phi, alpha) - f,2)

