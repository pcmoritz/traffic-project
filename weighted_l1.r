install.packages("glmnet")
library(glmnet)

install.packages("R.utils")
install.packages("R.matlab")
library(R.matlab)


data <- readMat('small_graph.mat')

glmnet(data$phi, data$f)
