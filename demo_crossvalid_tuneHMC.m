function [] = demo_crossvalid_tuneHMC()
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
randn('state', 1);
rand('twister', 1);    

%heads = { 'spiral2', 'iris', 'glass', 'wine', 'vowel200', 'vehicle200',...
%    'segment200', 'satimage200', 'letter200', 'mnist200'};
%heads = { 'spiral2', 'iris', 'glass', 'wine', 'vowel', 'vehicle', ...
%          'svmguide2'};
%heads = {'spiral2','halfcircles_N100K3','circles_N50K2','pinwheel_N50K5'};
%heads = { 'iris', 'glass', 'wine'};
%heads = {'mnist1000'};
%heads = {'spiral2'};
%heads = {'mnist1000'};
%heads = {'mnist200'};
%heads = {'halfcircles2_N100K3'};
%heads = {'mnist_0_4_Nk100'};
%heads = {'mnist_0_4_Nk50'};
%heads = {'mnist_Nk50K10'};
%heads = {'spiral2','circles_N50K2','pinwheel_N50K5','halfcircles2_N100K3'};
%heads = { 'iris', 'glass', 'wine'};
%heads = { 'vowel'};
%heads = {'halfcircles2_N100K3'};
heads = {'mnist_Nk50K10'};
heads = {'tomlins-2006-v2_database'};
heads = {'yeoh-2002-v2_database'};
heads = {'Expression_annotated_matrix_noNAs'};
%heads = {'mnist_0_4_Nk50'};
heads = {'mnist_Nk200K5'};
%heads = {'spiral2'};
%heads =
%{'spiral2','circles_N50K2','pinwheel_N50K5','halfcircles2_N100K3'};
%heads = {'iris', 'glass', 'wine'};
%heads = {'wine'};
heads = {'vowel'};
%heads = {'glass', 'wine','iris'};
%heads = {'glass'};
%heads = {'spiral2','circles_N50K2','pinwheel_N50K5','halfcircles2_N100K3'};
%heads = {'iris'};
heads = {'vowel'};
heads = {'wine'};

close all;
%num_fold = 1;
num_fold = 10;
options = [];
options.isPlot = 0;
options.hmc_isPlot = 0;
%options.isPlot = 20;
options.isGPLVMinit = 1;


for i = 1:numel(heads)
    fn = sprintf('data/%s.mat',heads{i})
    load(fn);
    [N,observed_dimension] = size(X);
    if num_fold > 1
        cv = cvpartition(N,'kfold',num_fold);
    end
    
    %for k = 1:num_fold
    for k = 1:5
    %for k = 6:10
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
        
        %latent_dimensions = {2,observed_dimension};
        latent_dimensions = {observed_dimension,2};
        if observed_dimension == 2 || observed_dimension > 30
            latent_dimensions = {2};
        end
        
        %options.num_iters = 10;
        options.num_iters = 5000;
        %options.num_iters = 100;
        %options.epsilon = 0.005;
        options.epsilon = 0.01;
        num_components = 5;
        options.Tau = 25;

        epsilons = { 0.003, 0.002 };
        %tune epsilon (HMC step parameter) so that acceptance rate becomes
        %close to 65%
        
        for j = 1:numel(latent_dimensions)
            
            %Infinite Warped Mixture Model (DP&GPLVM)
            options.isDP = 1;
            options.isGP = 1;
            
            num_iters_back = options.num_iters ;
            options.num_iters = 300;
            bestn = 1;
            bestnarate = 0;
            for n = 1:numel(epsilons)
                options.epsilon = epsilons{n};
                [hist_post, hist_params, Ls, hist_assignments, arate] = ...
                    gplvm_dpmix_integrate_infer(latent_dimensions{j},...
                    num_components,trainX,trainy,options);                
                fprintf('%s %d %f %f\n',heads{i},latent_dimensions{j},epsilons{n},arate);
                %if abs(bestnarate-0.65) > abs(arate-0.65)
                %    bestn = n;
                %    bestnarate = arate;
                %end
                bestn = n;
                if arate > 0.65
                    break
                end
            end       
            options.num_iters = num_iters_back ;
            options.epsilon = epsilons{bestn};
            
            %{
            [hist_post, hist_params, Ls, hist_assignments, arate] = ...
                gplvm_dpmix_integrate_infer(latent_dimensions{j},...
                num_components,trainX,trainy,options);
            ofn = sprintf('results_cv%d/result_cv_iwmm_%s_%d_%d.mat',num_fold,heads{i},latent_dimensions{j},k);
            save( ofn,'hist_post','hist_params','Ls','trainX','trainy','testX','testy','hist_assignments','options','arate');
            
            %Warp Model
            options.isDP = 0;
            options.isGP = 1;
            [hist_post, hist_params, Ls, hist_assignments, arate] = ...
                gplvm_dpmix_integrate_infer(latent_dimensions{j},...
                num_components,trainX,trainy,options);
            ofn = sprintf('results_cv%d/result_cv_wm_%s_%d_%d.mat',num_fold,heads{i},latent_dimensions{j},k);
            save( ofn,'hist_post','hist_params','Ls','trainX','trainy','testX','testy','hist_assignments','options','arate');
            %}
        end

        %{
        %infinite GMM
        options.isDP = 1;
        options.isGP = 0;
        [hist_post, hist_params, Ls, hist_assignments] = ...
            gplvm_dpmix_integrate_infer(latent_dimensions{j},...
            num_components,trainX,trainy,options);
        ofn = sprintf('results_cv%d/result_cv_gmm_%s_%d.mat',num_fold,heads{i},k);
        save( ofn,'hist_post','hist_params','Ls','trainX','trainy','testX','testy','hist_assignments','options');
        %}
    end
end
