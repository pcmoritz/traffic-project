import numpy as np

def text_to_np(text,delim='\n'):
    return np.array([float(x) for x in text.split(delim)])
