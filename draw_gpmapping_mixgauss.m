function draw_gpmapping_mixgauss( X, Y, mix, log_hypers, assignments,labels,circle_size,circle_alpha,N_points)

figure(5432100); clf;

[N,latent_dimension] = size(X);
observed_dimension = size(Y,2);
n_components = numel(mix.weights);

if nargin < 7
    circle_size = 0.05;
    circle_alpha = 0.02;
    N_points = 1000;
    %N_points = 10000;
end

latent_draws = NaN(N_points,latent_dimension);

cur_count = 1;
for m_ix = 1:n_components
    points_in_mix(m_ix) = ceil(N_points*mix.weights(m_ix));
    latent_draws(cur_count:cur_count+points_in_mix(m_ix)-1, :) = ....
        mvnrnd( mix.mus(m_ix, :), ...
                inv(mix.decomps(:, :, m_ix)'*mix.decomps(:, :, m_ix)),...
                points_in_mix(m_ix));
                %inv(mix.decomps(:, :, m_ix)'*mix.decomps(:, :,
                %m_ix))+eye(latent_dimension), ... %HACK
    cur_count = cur_count + points_in_mix(m_ix);
end

hyp(1) = -log_hypers.gamma/2;
hyp(2) = log_hypers.alpha/2;
Kc2 = covSEiso(hyp, latent_draws, X);

K = covSEiso(hyp, X);
K = K + eye(N)*max(exp(log_hypers.betainv), 1e-3);  % HACK

c_tfrm = Kc2*(K\Y);
[N,dim] = size(c_tfrm);
%latent_draws
%Kc2K = Kc2/K*Kc2';
for i = 1:N
    Kc2K = Kc2(i,:)/K*Kc2(i,:)';
    c_tfrm(i,:) = c_tfrm(i,:)+randn(1,dim)*(covSEiso(hyp,latent_draws(i,:))-Kc2K);
end

cur_count = 1;
for m_ix = 1:n_components
    ag_plot_little_circles(c_tfrm(cur_count:cur_count+points_in_mix(m_ix)-1, 1), ...
         c_tfrm(cur_count:cur_count+points_in_mix(m_ix)-1, 2), ...
         circle_size, colorbrew(m_ix), circle_alpha ); hold on;
    cur_count = cur_count + points_in_mix(m_ix);
end

% Draw the original data and current assigments
markers = {'x', 'o', 's', 'd', '.', '>', '<', '^'};
for z = 1:n_components
    idx = find(assignments(:,z)==1);
    plot(Y(idx, 1), Y(idx, 2), 'o', ...
        'MarkerEdgeColor', 'k');hold on;
        %'MarkerEdgeColor', 'k',...
        %'MarkerFaceColor', colorbrew(z));  hold on;
        %'Marker', markers{1+mod(z,numel(markers))}, ...
        %'Color', colorbrew(z));  hold on;
end

drawnow;

end


