import networkx as nx
import matplotlib.pyplot
import itertools

import os, sys
lib_path = os.path.abspath('YenKSP')
sys.path.append(lib_path)
import graph
import algorithms

def generate_small_graph():
  # we have 50 nodes, of which a 5*5 grid is for Caltec and a 5*5 grid
  # is for the streets (for now) --> imagine it as a 5 rows, 10 columns
  # grid, indexed like a matrix
  
  sensors = []

  # Generate directed road network
  G = nx.DiGraph()
  
  for j in range(0, 10):
      for k in range(0, 5):
          G.add_node(k * 10 + j, pos = (j, -k))
      
  for j in range(0, 9):
      for k in range(0, 4):
          G.add_edge(k * 10 + j, k * 10 + j + 1, weight=1)
          G.add_edge(k * 10 + j, (k+1) * 10 + j, weight=1)
  
  for j in range(0, 9):
      G.add_edge(4 * 10 + j, 4 * 10 + j + 1, weight=1)
  
  for k in range(0, 4):
      G.add_edge(k * 10 + 9, (k+1) * 10 + 9, weight=1)
  
  # Highways
  for j in range(0, 9):
      G.edge[j][j+1]['weight'] = 6
      sensors.append((j,j+1))
      G.edge[2*10 + j][2*10 + j+1]['weight'] = 4
      if j % 2 == 3:
          sensors.append((2*10 + j,2*10 + j+1))
      G.edge[4*10 + j][4*10 + j+1]['weight'] = 6
      sensors.append((4*10 + j,4*10 + j+1))
  
  # Medium roads
  for j in range(0, 9):
      for k in range(0, 4):
          if j % 2 == 0:
              G.edge[k*10 + j][(k+1)*10 + j]['weight'] = 3

  for (u, v, data) in G.edges(data=True):
      G.add_edge(v, u, weight = data['weight'])

  # Invert graph weights
  H = graph.DiGraph()
  
  for (u, v) in G.edges():
      H.add_edge(u, v, cost = 1/G.edge[u][v]['weight'])
  sensors_opposite = [(v,u) for (u,v) in sensors]
  sensors.extend(sensors_opposite)
  
  # Find k shortest routes between all 2 nodes
  routes = []
  
  for pair in itertools.product(range(0, 50), repeat=2):
      u = pair[0]
      v = pair[1]
      if u == v:
        continue
      # dijkstra would be routes.append(nx.shortest_path(G,source=v,target=w))
      k_shortest = algorithms.ksp_yen(H, u, v, max_k = 5)
      paths = map(lambda x: x['path'], k_shortest)
      if len(paths) > 0 and not(len(paths[0]) == 0):
          routes.extend(paths)
          
  return G, routes, sensors

if __name__ == '__main__':
  G, routes, sensors = generate_small_graph()
  # drawing:

  pos = nx.get_node_attributes(G,'pos')

  nx.draw(G,pos)

  edge_labels=dict([((u,v,),d['weight'])
                    for u,v,d in G.edges(data=True)])

  nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)

  matplotlib.pyplot.show()
