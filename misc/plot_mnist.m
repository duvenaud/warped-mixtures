function [] = plot_mnist(hist_post,hist_params,X)


cmap = colormap('gray');
colormap(1-cmap);
L = 28;
[N,D] = size(X);

scale = 300;

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
inds = randperm(N);
%inds = randsample(N,50);
for i = 1:numel(inds)
    A = reshape(X(inds(i),:),L,L);
    subimage(hist_params(end).X(inds(i),1),hist_params(end).X(inds(i),2),imrotate(A,90));
    hold on;
end

hold off;
axis off;
