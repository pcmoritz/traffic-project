traffic-project
===============

Code for the Compressed Sensing Traffic Project

SETUP
-----
    $ sudo easy_install pip
    $ sudo pip install networkx

    $ sudo pip install matplotlib

To update YenKSP to the latest versin, run
    $ git subtree pull --prefix YenKSP https://github.com/Pent00/YenKSP.git master --squash

To setup matpy1 [http://algoholic.eu/matpy/], run from Matlab
    $ mex matpy1/py.cpp -lpython2.7 -ldl
    $ On OSX, there is a bug with MEX compilation, resolved here [http://www.mathworks.com/support/solutions/en/data/1-FR6LXJ/]
