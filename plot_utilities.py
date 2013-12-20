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
        data.append(file_to_np("%s/%s" % (data_dir, data_file)))
    return np.array(data)

def file_to_np(file_path,cols=False,delim=None):
    with open(file_path) as f:
        if cols:
            data = []
            for line in f.readlines():
                data.append(text_to_np(line,delim=delim))
            return np.array(data)
        return np.array([float(x) for x in f.readlines()])

def fit(x, y, degree=1):
    coefficients = np.polyfit(x, y, degree)
    polynomial = np.poly1d(coefficients)
    xs = np.linspace(x.min(),x.max(),num=1000)
    ys = polynomial(xs)
    return (xs, ys)
