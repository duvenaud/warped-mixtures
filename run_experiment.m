% Code to reproduce all experiments
% ========================================

% Tomoharu Iwata
% David Duvenaud



% Run cross validation experiments
demo_crossvalid
% set num_fold (the number of cross-validation sets)
num_fold=1 % use all data

% Calculate rand index.
demo_clustering_cv

% Calculate test likelihood.
demo_densityestimation_cv

% Output rand index results in latex.
latexclustering

% Output density estimation results in latex.
latexdensityestimation

% Plot the results figures.
load('data/halfcircles2_N100K3.mat');
load('results_cv1/result_cv_iwmm_halfcircles2_N100K3_2_1.mat');
plot_iwmm_result(hist_params,hist_post,hist_assignments,X,y,'halfcircles2_N100K3');

