% A simple demo of the semi-supervised GP-LVM
%
% David Duvenaud
% Tomoharu Iwata
%
% April 2012

addpath('minFunc');
addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');


close all;
%clear all;

% Set the random seed, always the same for the datafolds.
randn('state', 1);
rand('twister', 1);    
   
load( 'spiral.mat' );
%load( 'roll1.mat' );
%load( 'simple2.mat' );
%load( 'one_curve.mat' );
%load( 'roll1.mat' );
%load( 'two.mat' );
%load( 'two_bends.mat' );
%load( 'dave2.mat' );
%load('from_manifold_s8');

% remove most of the data
X = X(1:2:end, :);
y = y(1:2:end, :);

%X(20:30, :) = [];
%y(20:30, :) = [];

observed_data = X; 
labels = y; 
latent_dimension = 2;
num_components = 2;

% Call the main function.
[latent_positions, mix, hypers] = ...
    gplvm_mix_infer(latent_dimension, num_components, observed_data);

latent_positions
