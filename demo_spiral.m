function demo_spiral()
% A simple demo of the warped mixture model.
%
% To try this code on another dataset, 
%
% David Duvenaud
% Tomoharu Iwata
%
% March 2013 2012
% ====================

addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');

% Set the random seed.
seed = 0;
randn('state', seed);
rand('twister', seed);    

% Load the dataset.
dataset = 'spiral2';
fn = sprintf('data/%s.mat', dataset);
load(fn);      % Load X (observed data) and y (true cluster labels)
trainX = X;
trainy = y;

% Set some options.
latent_dimensions = 2;     % Maximum latent dimension.
num_init_components = 3;   % How many clusters to start with.
options = [];
options.isDP = 1;          % Use Dirichlet Process prior. (vs fixed number)
options.isGP = 1;          % Use GP warping (vs no warping)
options.isGPLVMinit = 0;   % Initialize using GP-LVM.

% HMC sampler options. 
% Adjust these until you get a mix of accepts and rejects.
options.epsilon = 0.02;   % Step size.
options.Tau = 25;         % Number of steps.

% Plotting options.
options.isPlot = 10;       % How often to plot.
options.isMovie = 0;       % Whether to record frames.
options.hmc_isPlot = 1;    % Whether to plot hmc paths.

figure('Position',[100 200 1200 1000]); clf;
        
% Now call inference, with plotting turned on.
[sampled_mixtures, sampled_warpings, nlls, hist_assignments] = ...
    gplvm_dpmix_integrate_infer(latent_dimensions, num_init_components, ...
                                trainX,trainy,options);


