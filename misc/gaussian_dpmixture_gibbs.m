function gaussian_dpmixture_gibbs(X,n_components)

close all;

% post: posteriors
% Set the random seed, always the same for the datafolds.
randn('state', 3);
rand('twister', 2);    
addpath('util');

[N,dim] = size(X);

% Set priors for Gaussian-Wishert
prior.r = 1;
prior.nu = dim;
prior.S = eye(dim);
%prior.m = zeros(1,dim);
prior.m = mean(X,1);
prior.Chol = cholcov(prior.S);

% Dirichlet prior
prior.alpha = 1;
    
% initialize assigments with kmeans
assignments = zeros(N,n_components);
%cidx = kmeans(X,n_components);
cidx = randi(n_components,N,1);
for z = 1:n_components
    assignments(cidx==z,z) = 1;
end

% calculate posteriors for Gaussian-Wishart hyper-parameters
post.ns = NaN(n_components,1);
post.rs = NaN(n_components,1);
post.nus = NaN(n_components,1);
post.ms = NaN(n_components,dim);
post.Chols = NaN(dim,dim,n_components);
for z = 1:n_components
     post.ns(z) = sum(assignments(:,z),1);
     Xz = X(find(assignments(:,z)==1),:);
     post.rs(z) = prior.r+post.ns(z);
     post.nus(z) = prior.nu+post.ns(z);
     post.ms(z,:) = (prior.r*prior.m+sum(Xz,1))/(prior.r+post.ns(z));
     S = prior.S+Xz'*Xz+prior.r*(prior.m'*prior.m)-post.rs(z)*(post.ms(z,:)'*post.ms(z,:));
     post.Chols(:,:,z) = cholcov(S);
end

n_iters = 300;
for iter = 1:n_iters
    [L,assignments,post] = gaussian_dpmixture_gibbsstep(X,assignments,prior,post);
    Ls(iter) = L;
    if mod(iter,1) == 0
        %plot_mix_gauss_wishart(post);
        plot_gaussian_mixture(X,assignments,prior,post);
        figure(100); clf;
        plot(Ls);
        drawnow;
    end
end

end

function plot_gaussian_mixture(X,assignments,prior,post)

figure(123423); clf;

[~,n_components] = size(assignments);

for z = 1:n_components
    plot(X(find(assignments(:,z)==1),1),...
         X(find(assignments(:,z)==1),2),...
         'x','Color',colorbrew(z)); hold on;
end

mix.mus = post.ms;
for z = 1:n_components
    C = cholcov(inv(post.Chols(:,:,z)'*post.Chols(:,:,z)));
    mix.decomps(:,:,z) = sqrt(post.nus(z))*C;
end
%mix.weights = (post.ns+prior.alpha)./sum(post.ns+prior.alpha,1);
mix.weights = (post.ns)./sum(post.ns);

[xmin,xmax,ymin,ymax] = plot_contours( mix );
xlim( [xmin xmax] );
ylim( [ymin ymax] );
set(gcf, 'color', 'white');
drawnow;

end

