import networkx as nx
import matplotlib.pyplot
import numpy as np

def generate_trivial_graph():
  G = nx.Graph()
  
  G.add_node(0)
  G.add_node(1)
  G.add_node(2)
  G.add_node(3)
  
  G.add_edge(0, 1)
  G.add_edge(1, 2)
  G.add_edge(2, 3)
  
  routes = [[0, 1, 2], [0, 1], [3, 2], [3, 2, 1]]
  
  flows = {0 : 0.5, 3 : 0.1} # map from origin node to its flow
  
  return G, routes

if __name__ == '__main__':
  nx.draw(G)
  matplotlib.pyplot.show()

