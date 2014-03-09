function draw_gpmapping_mixgauss( X, Y, mix, log_hypers, assignments,labels,circle_size,circle_alpha,N_points)

% Plots the density manifolds in the observed space by sampling points in the
% latent space, and warping them according to the posterior over warpings.
%
% David Duvenaud
% Tomoharu Iwata
%
% 2012


[N,latent_dimension] = size(X);
observed_dimension = size(Y,2);
n_components = numel(mix.weights);

if nargin < 7
    circle_size = 0.05;
    circle_alpha = 0.02;
    N_points = 1000;
end

latent_draws = NaN(N_points,latent_dimension);

cur_count = 1;
for m_ix = 1:n_components
    points_in_mix(m_ix) = ceil(N_points*mix.weights(m_ix));
    latent_draws(cur_count:cur_count+points_in_mix(m_ix)-1, :) = ....
        mvnrnd( mix.mus(m_ix, :), ...
                inv(mix.decomps(:, :, m_ix)'*mix.decomps(:, :, m_ix)),...
                points_in_mix(m_ix));
    cur_count = cur_count + points_in_mix(m_ix);
end

% Compute Gram gram matrix.
hyp(1) = -log_hypers.gamma/2;
hyp(2) = log_hypers.alpha/2;
K = covSEiso(hyp, X) + eye(N)*max(exp(log_hypers.betainv), 1e-3);  % Add a little noise.

% Compute conditional posterior.
crosscov = covSEiso(hyp, latent_draws, X);
post_mean = crosscov*(K\Y);
prior_var = covSEiso(hyp, latent_draws, 'diag');
post_var = prior_var - sum(bsxfun(@times, crosscov/K, crosscov), 2);

samples = post_mean + randn(N_points, observed_dimension) .* repmat(post_var, 1, observed_dimension);


cur_count = 1;
for m_ix = 1:n_components
    ag_plot_little_circles(samples(cur_count:cur_count+points_in_mix(m_ix)-1, 1), ...
         samples(cur_count:cur_count+points_in_mix(m_ix)-1, 2), ...
         circle_size, colorbrew(m_ix), circle_alpha ); hold on;
    cur_count = cur_count + points_in_mix(m_ix);
end

% Draw the original data and current assigments
markers = {'x', 'o', 's', 'd', '.', '>', '<', '^'};
for z = 1:n_components
    idx = find(assignments(:,z)==1);
    plot(Y(idx, 1), Y(idx, 2), 'x', ...
        'MarkerEdgeColor', 'k');hold on;
        %'MarkerEdgeColor', 'k',...
        %'MarkerFaceColor', colorbrew(z));  hold on;
        %'Marker', markers{1+mod(z,numel(markers))}, ...
        %'Color', colorbrew(z));  hold on;
end

drawnow;

end


