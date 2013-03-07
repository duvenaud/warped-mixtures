function [alpha] = sampling_dphyperparameter( alpha, n, k, a, b )
%alpha: Dirichlet process hyperparameter
%n: number of samples
%k: number of clusters
%a,b: beta prior paramters for alpha

num_iters = 20;
for iter = 1:num_iters
    eta = betarnd(alpha+1,n);
    s = binornd(1,(a+k-1)/(a+k-1+n*(b-log(eta))));
    alpha = gamrnd(a+k+s-1,b-log(eta));
end
