function [] = plot_faces(hist_post,hist_params,X)

%how to use this:
% 1. load('data/umist_downsampled3');
% 2. load('results_faces/demo_faces2.mat');
% 3. plot_faces(hist_post,hist_params,X)

cmap = colormap('gray');
colormap(1-cmap);
%L = 28;
L = 32;
[N,D] = size(X);

% Rescale dataset to [-1, 1].
%X = X - repmat(min(X,[],1), N,1);
%X = X./repmat(max(X,[],1),  N,1);
%X = X * 2 - 1;
X = X./255;
    
scale = 100;
%scale = 1;

post = hist_post(end);
n_components = size(post.ms,1);
mix.weights = (post.ns)./sum(post.ns);
mix.mus = post.ms*scale;
%mix.mus = post.ms;
for z = 1:n_components
    C = chol(inv(post.Chols(:,:,z)'*post.Chols(:,:,z)));
    %mix.decomps(:,:,z) = sqrt(post.nus(z))*C*sqrt(scale);
    mix.decomps(:,:,z) = sqrt(post.nus(z))*C/scale;
end
plot_contours_one( mix );
hold on;

hist_params(end).X = hist_params(end).X*scale;
inds = 1:N;
%inds = randperm(N);
%inds = randsample(N,50);
for i = 1:numel(inds)
    A = reshape(X(inds(i),:),L,L);
    subimage(hist_params(end).X(inds(i),1),hist_params(end).X(inds(i),2),imrotate(A,180));
    hold on;
end

hold off;
axis off;