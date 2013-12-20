import numpy as np

def text_to_np(text,delim=None):
    if delim:
        return np.array([float(x) for x in text.split(delim)])
    return np.array([float(x) for x in text.split()])

def dir_to_np(data_dir):
    import os
    data = []
    data_files = os.listdir(data_dir)
    for data_file in data_files:
        if data_file[0] == '.':
            continue
        with open("%s/%s" % (data_dir, data_file)) as f:
            data.append([float(x) for x in f.readlines()])
    return np.array(data)
