% Generate synthetic data from Ryan Adam's pinwheel code.
%
% David Duvenaud
% May 2012

clear all;

% Set the random seed, always the same for the datafolds.
randn('state', 0);
rand('twister', 0);  

[X, y] = pinwheel(0.1, 0.2, 3, 66, 1);
subplot(2,2,1);
plot(X(:,1), X(:,2), '.');
grid;
ylim([-2 2]);
xlim([-2 2]);
title('pinwheel(0.3, 0.3, 3, 1000, 0.25);');
save 'pinwheel_3_arms_200_points'


[X, y] = pinwheel(0.04, 0.3, 5, 40, .8);
subplot(2,2,2);
plot(X(:,1), X(:,2), '.');
grid;
ylim([-2 2]);
xlim([-2 2]);
title('pinwheel(0.1, 0.3, 5, 1000, 0.25);');
save 'pinwheel_5_arms_200_points'

[X, y] = pinwheel(0.1, 0.4, 4, 50, 0.75);
subplot(2,2,3);
plot(X(:,1), X(:,2), '.');
grid;
ylim([-2 2]);
xlim([-2 2]);
title('pinwheel(0.1, 0.2, 4, 1000, 0.25);');
save 'pinwheel_4_arms_200_points'

[X, y] = pinwheel(0.1, 0.3, 2, 100, 1);
subplot(2,2,4);
plot(X(:,1), X(:,2), '.');
grid;
ylim([-2 2]);
xlim([-2 2]);
title('pinwheel(0.1, 0.3, 2, 1000, 0.5);');
save 'pinwheel_2_arms_200_points'