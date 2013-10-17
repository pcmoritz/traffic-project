import networkx as nx
import matplotlib.pyplot

G = nx.Graph()

G.add_node(0)
G.add_node(1)
G.add_node(2)
G.add_node(3)

G.add_edge(0, 1)
G.add_edge(1, 2)
G.add_edge(2, 3)

routes = [[0, 1, 2], [0, 1], [3, 2], [3, 2, 1]]

nx.draw(G)
matplotlib.pyplot.show()

