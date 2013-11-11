from __future__ import division

import networkx as nx
import itertools

import os, sys
lib_path = os.path.abspath('YenKSP')
sys.path.append(lib_path)
import graph
import algorithms

def generate_small_graph(num_cols=5, num_rows=5, num_routes_per_od_pair=2):
  # we have n*m nodes, (((of which a 5*5 grid is for Caltec and a 5*5 grid
  # is for the streets (for now) --> imagine it as a 5 rows, 10 columns
  # grid, indexed like a matrix)))
  
  sensors = []

  # Generate directed road network
  G = nx.DiGraph()
  n = num_cols
  m = num_rows
  r = num_routes_per_od_pair

  for j in range(0, n):
      for k in range(0, m):
          G.add_node(k * n + j, pos = (j, -k))
      
  for j in range(0, n-1):
      for k in range(0, m-1):
          G.add_edge(k * n + j, k * n + j + 1, weight=1)
          sensors.append((k * n + j, k * n + j + 1))
          G.add_edge(k * n + j, (k+1) * n + j, weight=1)
          sensors.append((k * n + j, (k+1) * n + j))
  
 # Manually get the last row
  for j in range(0, n-1):
      G.add_edge((m-1) * n + j,(m-1) * n + j + 1, weight=6) 
      sensors.append(((m-1) * n + j, (m-1) * n + j + 1))
      # had to do this for this small node case to get at least 2 highways...

 # Manually set the last column
  for k in range(0, m-1):
      G.add_edge(k * n + n-1, (k+1) * n + n-1, weight=1)
      sensors.append((k * n + n-1, (k+1) * n + n-1));

  # Set bigger road weights
  for k in range(0, m-1):
    for j in range(0, n-1):
    # Highways
      if k % 4 == 0:
        G.edge[k*n + j][k*n + j+1]['weight'] = 6
        # sensors.append((k*n + j,k*n + j+1))

    # Big streets  
      if k % 4 == 2:
        G.edge[k*n + j][k*n + j+1]['weight'] = 3
        # Philipp: Hungry for sensors
        # if j % 3 == 0:
        # sensors.append((k*n + j,k*n + j+1))

    # Half big streets
      if j % 2 == 0:
        G.edge[k*n + j][(k+1)*n + j]['weight'] = 2
        # oh my gosh, I want more sensors
        # sensors.append((k*n + j,(k+1)*n + j))
          
        
  for (u, v, data) in G.edges(data=True):
      G.add_edge(v, u, weight = data['weight'])

  # Invert graph weights
  H = graph.DiGraph()
  
  for (u, v) in G.edges():
      H.add_edge(u, v, cost = 1./G.edge[u][v]['weight'])

  # Add opposite sensors
  sensors_opposite = [(v,u) for (u,v) in sensors]
  sensors.extend(sensors_opposite)
  
  # Find k shortest routes between all 2 nodes
  routes = []
  
  for pair in itertools.product(range(0, n*m), repeat=2):
      u = pair[0]
      v = pair[1]
      if u == v:
        continue
      # dijkstra would be routes.append(nx.shortest_path(G,source=v,target=w))
      k_shortest = algorithms.ksp_yen(H, u, v, max_k = r)
      paths = map(lambda x: x['path'], k_shortest)
      if len(paths) > 0 and not(len(paths[0]) == 0):
          routes.extend(paths)
          
  return G, routes, sensors

if __name__ == '__main__':
  G, routes, sensors = generate_small_graph()
  # drawing:

  print sensors
  print len(sensors)

  pos = nx.get_node_attributes(G,'pos')

  nx.draw(G,pos)

  edge_labels=dict([((u,v,),d['weight'])
                    for u,v,d in G.edges(data=True)])

  nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)

  nx.draw_networkx_edges(G, pos, edgelist=sensors, width=3, alpha=0.5,
                         edge_color='b')

  print routes

  import matplotlib.pyplot
  matplotlib.pyplot.show()
