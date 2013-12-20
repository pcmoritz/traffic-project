import numpy as np

def text_to_np(text,delim=None):
    if delim:
        return np.array([float(x) for x in text.split(delim)])
    return np.array([float(x) for x in text.split()])
