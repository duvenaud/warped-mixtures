function [xmin, xmax, ymin, ymax] = plot_contours( mix )
%
% Plots the contours of a mixture of Gaussians.
%
% mix specifies a weighted mixture of Gaussians, with 
%    mu
%    decomps
%    weights
%
% David Duvenaud
% Tomoharu Iwata
%
% April 2012

% Generate contours
n_contours = 3;
contour_radiuses = [3 2 1];
points_per_contour = 100;
angles = linspace(0, 2*pi, points_per_contour);
ix = 1;

xmin = Inf;
xmax = -Inf;
ymin = Inf;
ymax = -Inf;

num_clusters = size(mix.mus, 1 );

for m_ix = 1:num_clusters
    for c_ix = 1:n_contours
        start_ix = ix;
        for angle = angles
            cur_pos =  [cos(angle) sin(angle)];
            %mh_dst = sqrt( cur_pos * (mix.decomps(:, :,...
            %m_ix)'*mix.decomps(:, :, m_ix)) * cur_pos');
            mh_dst = sqrt( cur_pos * (mix.decomps(1:2, 1:2, m_ix)'*mix.decomps(1:2, 1:2, m_ix)) * cur_pos');
            c(ix, 1) = mix.mus(m_ix, 1) + cos(angle) / mh_dst * contour_radiuses(c_ix);
            c(ix, 2) = mix.mus(m_ix, 2) + sin(angle) / mh_dst * contour_radiuses(c_ix);
            ix = ix + 1;
        end
        h = fill( c(start_ix:ix-1, 1), c(start_ix:ix-1, 2), colorbrew(m_ix) ); hold on;
        %set(h,'EdgeColor','none', 'FaceAlpha', mix.weights(m_ix)/2);
        set(h,'EdgeColor','none', 'FaceAlpha', mix.weights(m_ix));
        
        ymin = min(ymin, min( c(start_ix:ix-1, 2) ));
        xmin = min(xmin, min( c(start_ix:ix-1, 1) ));
        ymax = max(ymax, max( c(start_ix:ix-1, 2) ));
        xmax = max(xmax, max( c(start_ix:ix-1, 1) ));
    end
end
