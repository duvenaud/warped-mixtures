function [] = control_analysis()
% A simple demo of warped mixture models.
%
% David Duvenaud
% Tomoharu Iwata
%
% April 2012

addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');

close all;

% Set the random seed.
randn('state', 1);
rand('twister', 1);    
   
%load( 'PA_data' );

%observed_data = PA_data_normatedScores(:,:);
%load spiral2_n50
%observed_data = X;

observed_data = NaN( 46, 9 );
observed_data(1:23, : ) = mvnrnd( ones( 9, 1), eye(9,9), 23 );  % healthy
observed_data(24:46, : ) = mvnrnd( zeros( 9, 1), 3.*eye(9,9), 23 );  % sick

% whiten the data
for d = 1:size(observed_data, 2)
    observed_data(:, d) = observed_data(:, d) - mean(observed_data(:, d));
    observed_data(:, d) = observed_data(:, d) ./ std(observed_data(:, d));
end

latent_dimension = 9;
num_components = 1;

options.isPlot = 1000;
options.num_iters = 10000;

% Call the main function.
[hist_post, hist_params, Ls, assignments] = ...
    gplvm_dpmix_integrate_infer(latent_dimension, num_components,...
    observed_data, [], options);

eca = average_coassignment( assignments );
figure(123); imagesc(eca);

sorted_eca = group_matrix( eca, assignments{end});
figure(246); imagesc(sorted_eca);

%save control

asdf = 1;

keyboard;
