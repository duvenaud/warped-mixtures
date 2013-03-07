function draw_latent_representation( X, mix, assignments, labels )

figure(100); clf;

%mix.decomps

% Plot mixture components.
if nargin > 1
%if 0
    [xmin, xmax, ymin, ymax] = plot_contours( mix );
else
    xmin = min( X(:,1) );
    xmax = max( X(:,1) );
    ymin = min( X(:,2) );
    ymax = max( X(:,2) );
end

markers = {'x', 'o', 's', 'd', '.', '>', '<', '^'};

if nargin > 2
    if nargin > 3
        K = max(labels); %number of classes
        for k = 1:K
            idxs = find(labels==k);
            plot( X(idxs,1), X(idxs,2), markers{1+mod(k,numel(markers))}, ...
                  'Color', colorbrew(k));
            hold on;
        end
    else
        cmap = colormap('jet');
        num_bins = size(cmap,1);
        N = size(X,1);
        for i = 1:N
            plot( X(i,1), X(i,2), ...
                markers{1+mod(find(assignments(i,:)),numel(markers))},...
                'Color', cmap(floor((i/N)*(num_bins-1))+1,:));
            hold on;
        end
    end
else
    %plot( X(:,1), X(:,2), '.' ); hold on;
    cmap = colormap('jet');
    num_bins = size(cmap,1);
    N = size(X,1);
    for i = 1:N
        plot( X(i,1), X(i,2), 'x',...
            'Color', cmap(floor((i/N)*(num_bins-1))+1,:));
        hold on;
    end
end

xlim( [xmin xmax] );
ylim( [ymin ymax] );
set(gcf, 'color', 'white');
%axis off;
drawnow;



