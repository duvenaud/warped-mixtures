function [ X, y ] = paint_dataset( dataset_name )
% a little paint program to generate toy datasets
%
% David Duvenaud
% Aug 2009
% =====================


figure;
axis([ -1 1 -1 1 ])
hold on
title( 'Left = blue, Right = red, Space = done');

amount_each_time = 10;
data = [];
classlabels = [];
for i = 1:30
    [xi,yi,but] = ginput(1);
    if but == 3
        but = 2;
    end
    if but == 32
        break;
    end

    % generate new points
    data = [ data; mvnrnd( [ xi, yi ], eye(2)./2000, amount_each_time ) ];
    classlabels = [ classlabels; repmat( but, amount_each_time, 1 )] ;
    
    reds = classlabels == 1;
    blues = classlabels == 2;
    plot(data(reds,1), data(reds,2), 'r.'); hold on;
    plot(data(blues,1), data(blues,2), 'b.'); hold on;
end


X = data;
y = classlabels;

% randomize the order
perm = randperm( length(X) );

X = X(perm, :);
y = y(perm, :);


save( [ dataset_name '.mat' ], 'X', 'y' );
saveas( gcf, [ dataset_name, '.png' ] );
