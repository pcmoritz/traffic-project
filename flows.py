import collections
import random

import matplotlib
import networkx as nx
import numpy.random

import small_graph

def annotate_with_flows(graph, routes, flow_from_each_node=1.0, sparsity=0.1):
  '''Generate traffic from each origin onto some small fraction of its routes, and compute the amount of flow at each edge.'''
  
  # All route indices are with respect to _routes_.
  route_indices_by_origin = collections.defaultdict(list)
  for i, route in enumerate(routes):
    route_indices_by_origin[route[0]].append(i)
  
  flow_portions = [0] * len(routes)
  
  for node in graph.nodes():
    route_indices_from_node = route_indices_by_origin[node]
    num_nonzero_routes = max(1, int(sparsity * len(route_indices_from_node)))
    
    selected_route_indices = random.sample(route_indices_from_node, num_nonzero_routes)
    selected_route_weights = numpy.random.dirichlet([1] * num_nonzero_routes, 1)[0]
    
    for i, w in zip(selected_route_indices, selected_route_weights):
      flow_portions[i] = w
      
      for u, v in zip(routes[i], routes[i][1:]):
        edge = graph.edge[u][v]
        current_flow = edge['flow'] if 'flow' in edge else 0
        edge['flow'] = current_flow + flow_from_each_node * w
  
  return flow_portions
          
if __name__ == '__main__':
  graph, routes, sensors = small_graph.generate_small_graph()
  annotate_with_flows(graph, routes)

  pos = nx.get_node_attributes(graph, 'pos')
  nx.draw(graph,pos)
  
  edge_labels = collections.defaultdict(float)
  for u, v, d in graph.edges(data=True):
    if u > v:
      u, v = v, u
    edge_labels[(u, v)] += d['flow'] if 'flow' in d else 0
#  edge_labels=dict([((u,v,),d['flow'] if 'flow' in d else 0)
#                    for u,v,d in graph.edges(data=True)])
  nx.draw_networkx_edge_labels(graph, pos, edge_labels=edge_labels)

  matplotlib.pyplot.show()
