import networkx as nx
import matplotlib.pyplot
import itertools

from YenKSP import graph
from YenKSP import algorithms

def generate_small_graph():
  # we have 50 nodes, of which a 5*5 grid is for Caltec and a 5*5 grid
  # is for the streets (for now) --> imagine it as a 5 rows, 10 columns
  # grid, indexed like a matrix
  
  G = nx.Graph()
  
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
  
  for j in range(0, 9):
      G.edge[j][j+1]['weight'] = 6
      G.edge[2*10 + j][2*10 + j+1]['weight'] = 6
      G.edge[4*10 + j][4*10 + j+1]['weight'] = 6
  
  for j in range(0, 9):
      for k in range(0, 4):
          if j % 2 == 0:
              G.edge[k*10 + j][(k+1)*10 + j]['weight'] = 3
  
  H = graph.DiGraph()
  
  for (u, v) in G.edges():
      H.add_edge(u, v, cost = G.edge[u][v]['weight'])
      H.add_edge(v, u, cost = G.edge[u][v]['weight'])
  
  # finding shortest paths
  
  routes = []
  
  for pair in itertools.product(range(0, 50), repeat=2):
      u = pair[0]
      v = pair[1]
      # dijkstra would be routes.append(nx.shortest_path(G,source=v,target=w))
      k_shortest = algorithms.ksp_yen(H, u, v, max_k = 5)
      paths = map(lambda x: x['path'], k_shortest)
      if len(paths) > 0 and not(len(paths[0]) == 0):
          routes.extend(paths)
          
  return G, routes

if __name__ == '__main__':
  G, routes = generate_small_graph()
  # drawing:

  pos = nx.get_node_attributes(G,'pos')

  nx.draw(G,pos)

  edge_labels=dict([((u,v,),d['weight'])
                    for u,v,d in G.edges(data=True)])

  nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)

  matplotlib.pyplot.show()
