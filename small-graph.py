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
    G.edge[j][j+1]['weight'] = 3
    G.edge[2*10 + j][2*10 + j+1]['weight'] = 3
    G.edge[4*10 + j][4*10 + j+1]['weight'] = 3

print(nx.shortest_path(G,source=19,target=0))

pos = nx.get_node_attributes(G,'pos')

nx.draw(G,pos)

edge_labels=dict([((u,v,),d['weight'])
                  for u,v,d in G.edges(data=True)])

nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)

matplotlib.pyplot.show()
