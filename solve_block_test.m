% three blocks, each one with 10 variables
% we have 15 constraints

Phi = randn(20, 30);
alpha = abs(randn(30, 1));
alpha(1:10) = alpha(1:10)/sum(alpha(1:10));
alpha(11:20) = alpha(11:20)/sum(alpha(11:20));
alpha(21:30) = alpha(21:30)/sum(alpha(21:30));
f = Phi * alpha;

block = [11 20];
lambda = 1.5;

before = alpha(1:10);
after = alpha(21:30);

r1 = solve_block(Phi, alpha, f, block, lambda);
r2 = solve_block_hot_start_lp(Phi, alpha, f, block);

p = TestParameters();
p.L1 = [ones(1, 10), zeros(1, 20); ...
    zeros(1, 10), ones(1, 10), zeros(1, 10); ...
    zeros(1, 20), ones(1, 10)];
p.Phi = Phi; p.f = f; p.n = length(alpha);
p.block_sizes = [10 10 10];
p.blocks = [1, 10; 11, 20; 21, 30];

r3 = cvx_hot_start_lp(p);

r4 = cvx_block_descent_L_infty(p);

[[before; r1; after] - alpha, ...
    [before; r2; after] - alpha, ...
    r3 - alpha, ...
    r4 - alpha]

sum(abs(r3-alpha))
sum(abs(r4-alpha))
