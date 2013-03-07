function [F] = demo_viz()
% A simple demo of the warped mixture models
%
% David Duvenaud
% Tomoharu Iwata
%
% April 2012

addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');

% Set the random seed, always the same for the datafolds.
seed = 0;
randn('state', seed);
rand('twister', seed);    

heads = {'spiral2'};
%heads = {'umist_downsampled'};

%close all;
num_fold = 1;
%num_fold = 10;
options = [];
options.isPlot = 50;
options.isMovie = 0;
%options.hmc_isPlot = 1;
options.hmc_isPlot = 0;
%options.isPlot = 20;
options.isGPLVMinit = 0;

for i = 1:numel(heads)
    fn = sprintf('data/%s.mat',heads{i})
    load(fn);
    [N,observed_dimension] = size(X);
    
    % Rescale dataset to [-1, 1].
    X = X - repmat(min(X,[],1), N,1);
    X = X./repmat(max(X,[],1),  N,1);
    X = X * 2 - 1;
    assert(all(max(X, [], 1) <= 1))
    assert(all(min(X, [], 1) >= -1))
    if num_fold > 1
        cv = cvpartition(N,'kfold',num_fold);
    end
    
    for k = 1:num_fold
        if num_fold > 1
            trainX = X(cv.training(k),:);
            testX = X(cv.test(k),:);
            trainy = y(cv.training(k));
            testy = y(cv.test(k));
        else
            trainX = X;
            testX = [];
            trainy = y;
            testy = [];
        end
        
        latent_dimensions = {2};
        
        %options.num_iters = 4000;
        %options.epslion = 0.01;
        %options.Tau = 25;
        
        options.epsilon = 0.01;
        options.Tau = 1;
        options.prior_r = 1;
        num_components = 3;
        
        %Infinite Warped Mixture Model (DP&GPLVM)
        options.isDP = 1;
        options.isGP = 1;
        for j = 1:numel(latent_dimensions)
            [hist_post, hist_params, Ls, hist_assignments,F] = ...
                gplvm_dpmix_integrate_infer(latent_dimensions{j},...
                num_components,trainX,trainy,options);
            %movie(F);
            %movie2avi(F,'animation.avi');
        end
    end
end
