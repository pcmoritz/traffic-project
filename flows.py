import collections
import random

import matplotlib
import networkx as nx
import numpy.random

import small_graph

def get_route_indices_by_origin(routes):
  route_indices_by_origin = collections.defaultdict(list)
  for i, route in enumerate(routes):
    route_indices_by_origin[route[0]].append(i)
  return route_indices_by_origin

def new_dict_OD(routes):
  dict_OD = collections.defaultdict(list)
  for i, route in enumerate(routes):
    dict_OD[route[0]] = collections.defaultdict(list)
  return dict_OD

def get_route_indices_by_OD(routes):
  route_indices_by_OD = new_dict_OD(routes)
  for i, route in enumerate(routes):
    route_indices_by_OD[route[0]][route[-1]].append(i)
  return route_indices_by_OD

def annotate_with_flows(graph, routes, flow_from_each_node=1.0, num_nonzero_routes=2):
  '''Generate traffic from each origin onto some small fraction of its routes, \
          and compute the amount of flow at each edge.'''
  
  # collect routes by origin or by OD pair
  # Note: All route indices are with respect to _routes_.
  route_indices_by_origin = get_route_indices_by_origin(routes)
  route_indices_by_OD = get_route_indices_by_OD(routes)

  flow_portions = [0] * len(routes) # from origin
  flow_portions_OD = [0] * len(routes) # from origin to destination
  flow_OD = new_dict_OD(routes)

  # initialize the flows, in case a node is not in the interior of any route
  for n in graph.nodes():
    graph.node[n]['2nd_flow'] = {}

  # initialize all flows on edges to 0
  for (u,v) in graph.edges():
      graph.edge[u][v]['flow'] = 0
  
  # sample routes and compute aggregate first-order, second-order info on 
  # origins and origin-destination pairs
  for origin in graph.nodes():
    # consider all routes out of origin
    route_indices_from_origin = route_indices_by_origin[origin]
#    num_nonzero_routes = max(1, int(sparsity * len(route_indices_from_origin)))
    # select routes with non-zero flow
    selected_route_indices = sorted(random.sample(route_indices_from_origin,
            num_nonzero_routes))
    # probability prior (uniform dirichlet) on non-zero flow routes
    selected_route_weights = numpy.random.dirichlet([1] * num_nonzero_routes,
            1)[0]

    for i, w in zip(selected_route_indices, selected_route_weights):
      flow_portions[i] = w
      
      # add up flows on each link
      for u, v in zip(routes[i], routes[i][1:]):
        graph.edge[u][v]['flow'] += flow_from_each_node * w

      # add up "turn" information on each transition
      # p = predecessor, n = node, s = successor
      for p, n, s in zip(routes[i], routes[i][1:], routes[i][2:]):
        # add "second order flow"
        node = graph.node[n]
        current_flow = node['2nd_flow'][(p, s)][0] if (p, s) in \
                node['2nd_flow'] else 0
        current_routes = node['2nd_flow'][(p, s)][1] if (p, s) in \
                node['2nd_flow'] else set()
        node['2nd_flow'][(p, s)] = (current_flow + flow_from_each_node * w,
                current_routes | set([i]))

    # normalize flows for each OD pair
    for dest in graph.nodes():
      # normalize weights per OD pair
      selected_route_indices_OD = route_indices_by_OD[origin][dest]
      total = sum(flow_portions[i] for i in selected_route_indices_OD)
      flow_OD[origin][dest] = total
      if total == 0:
          continue
      for i in selected_route_indices_OD:
          flow_portions_OD[i] = flow_portions[i]/total
      
  return (flow_portions, flow_portions_OD,flow_OD) # used to generate real alpha
          
if __name__ == '__main__':
  graph, routes, sensors = small_graph.generate_small_graph()
  
  print "Graph: "
  print graph
  print "Routes: "
  print routes
  print len(routes)
  print "Sensors: "
  print sensors
  
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
  for u, v, d in graph.edges(data=True):
    if u > v:
      u, v = v, u
    edge_labels[(u, v)] = round(edge_labels[(u, v)], 4)
  nx.draw_networkx_edge_labels(graph, pos, edge_labels=edge_labels)

  matplotlib.pyplot.show()
