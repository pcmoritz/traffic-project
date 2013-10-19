install.packages("glmnet")
library(glmnet)

install.packages("R.utils")
install.packages("R.matlab")
library(R.matlab)

data <- readMat('small_graph.mat')
m <- dim(data$phi)[1]
n <- dim(data$phi)[2]

# calculate the sum-to-one constraint matrix

num.routes <- data$num.routes # each entry is associated with one origin
cum.nroutes = c(0, cumsum(num.routes))

# L1 constraint matrix
L1 = matrix(0, length(num.routes), n)

for(j in 1:length(num.routes)) {
    from = cum.nroutes[j] + 1;
    to = cum.nroutes[j + 1];
    L1[j,from:to] = matrix(1, 1, to-from+1)
}

a = dim(L1)[1]

large.penalty = 10000000

X = rbind(data$phi, large.penalty * L1)
y = rbind(data$f, large.penalty * matrix(1, a, 1))

result <- glmnet(X, y, intercept=FALSE, lower.limits=matrix(0.0, 1, n))
coef(result, s=0.01)

# as.vector(coef(result, s=0.01)[1:n])

X %*% as.matrix(coef(result, s=0.01)[1:n])
