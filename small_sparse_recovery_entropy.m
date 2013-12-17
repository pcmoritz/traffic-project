%% Usage
% Run this to get the appropriate test file:
% python random_matrix.py --prefix 'blah' --num_blocks 2 --num_vars_per_block 10 --num_nonzeros 4 --num_constraints 10

%% cvx code for sparse recovery of on small graphs
clear all;
cvx_solver mosek;

%% Read in graph
load('blahrandom_matrix.mat')

Phi = sparse(phi);
m = size(Phi,1);
n = size(Phi,2);

%% Define parameters
min_a = Inf;
min_val = Inf;
lambda = 1e-5;
Phi_original = Phi;

tic
num_routes = int64(block_sizes); % each entry is associated with one origin
cum_nroutes = int64([0; cumsum(double(block_sizes))]);

%% L1 constraint matrix
a = zeros(n, 1);
L1 = zeros(length(num_routes),n);
for j=1:length(num_routes)
    from = cum_nroutes(j) + 1;
    to = cum_nroutes(j + 1);
    L1(j,from:to) = ones(1,to-from+1);
    a(from:to) = ones(to - from + 1, 1) / double(to - from + 1);
end

%% Find a feasible solution
 cvx_begin quiet
    variable a(n)
    minimize 0
    
    subject to
    % square_pos(norm(Phi * a - f, 2)) <= 1e-6
    Phi * a == f
    a >= 0
    L1 * a == ones(length(num_routes), 1)
cvx_end

obj = @(a) -sum(a .* log(a + 1e-10));

%% Iteratively minimize entropy
num_iterations = 1000;
prev_ent = 0;
curr_ent = obj(a);
a_delta = 1;

c1 = 1e-2;
c2 = 0.9;

for i=1:num_iterations
    % y = -a .* log(a + 1e-10) - a; % Newton's method update
    grad = -log(a + 1e-10)-1;      % Gradient
    y = grad;
    
    cvx_begin quiet
        variable a_delta(n)
        minimize( y' * a_delta )
        subject to
        % square_pos(norm(Phi * (a + a_delta) - f, 2)) <= 1e-6
        square_pos(norm(a_delta, 2)) >= norm(a) * 0.1
        Phi * (a + a_delta) == f
        (a + a_delta) >= 0
        L1 * (a + a_delta) == ones(length(num_routes), 1)
    cvx_end
    a_delta
    
    obj_a = obj(a);
    magnitude = 1;
    
    while magnitude > 1e-5
        new_a = a + magnitude * a_delta;
        obj_new_a = obj(new_a);
        if obj_new_a < obj_a
            fprintf('%f < %f\n', obj_new_a, obj_a);
            a = new_a;
            break
        end
        magnitude = magnitude * 0.8;
    end
    %{
    k = 0;
    while true
        new_a = a + magnitude * a_delta;
        obj_new_a = obj(new_a);

        if obj_new_a <= obj_a + c1 * magnitude * dot_adelta_grad
%            grad_new_x = grad(new_x);
%            if dot(-grad_x, grad_new_x) >= c2 * dot_grad_grad
                break
%            end
        end
        magnitude = magnitude * 0.8;
            
        k = k + 1;
        if k > 20
%            fprintf('error\n')
            break
        end
    end
    a = new_a;
    %}    
    %{
    if norm(a_delta,1) >= 1e-15 % curr_ent < prev_ent - 1e-17
        disp('down')
        cvx_begin quiet
            variable a_delta(n)
            minimize( y' * a_delta )

            subject to
            % square_pos(norm(Phi * (a + a_delta) - f, 2)) <= 1e-6
            Phi * (a + a_delta) == f
            (a + a_delta) >= 0
            L1 * (a + a_delta) == ones(length(num_routes), 1)
        cvx_end
    else
        disp('up')
        cvx_begin quiet
            variable a_delta(n)
            minimize( -y' * a_delta )

            subject to
            % square_pos(norm(Phi * (a + a_delta) - f, 2)) <= 1e-6
            Phi * (a + a_delta) == f
            (a + a_delta) >= 0
            L1 * (a + a_delta) == ones(length(num_routes), 1)
        cvx_end

    end
    a = a + a_delta;
    % a(1:num_routes(1))'
    %}
    % Compute entropy of a
    %{
    t = zeros(length(num_routes), 1);
    for j=1:length(num_routes)
        from = cum_nroutes(j) + 1;
        to = cum_nroutes(j + 1); 
        t(j) = -sum(a(from:to) .* log(a(from:to) + 1e-10));
    end
    prev_ent = curr_ent;
    curr_ent = sum(t);
    %}
    fprintf('%d/%d: a_delta %f, opt %f, ent %f, prev_ent %f, err %f\n', i, num_iterations, ...
        sum(abs(a_delta)), cvx_optval, obj_new_a, obj_a, norm(real_a - a, 1));
    
    if norm(magnitude * a_delta) < 1e-3
        break
    end    
end
toc

error = norm(real_a - a, 1)
comparison = [real_a a];
