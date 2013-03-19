function [X,y] = mixnormwishrnd( post, n_points )
%random sampling from mixture of normal-wishart distribution

[n_components,dimension] = size(post.ms);
invCs = NaN(dimension,dimension,n_components);
invSs = NaN(dimension,dimension,n_components);
for z = 1:n_components
    S = post.Chols(:,:,z)'*post.Chols(:,:,z);
    invSs(:,:,z) = inv(S);
    invCs(:,:,z) = chol(invSs(:,:,z));
end

X = NaN(n_points,dimension);
y = NaN(n_points,1);
for n = 1:n_points
    assignment = mnrnd(1,post.ns./sum(post.ns));
    z = find(assignment==1);
    %sample precision by Wishart
    [R,invCs(:,:,z)] = wishrnd(invSs(:,:,z),post.nus(z),invCs(:,:,z));
    %sample mean by Gaussian
    mu = mvnrnd(post.ms(z,:),inv(post.rs(z)*R));
    %sample point by Gaussian
    X(n,:) = mvnrnd(mu,inv(R));
    y(n,1) = z;
end
