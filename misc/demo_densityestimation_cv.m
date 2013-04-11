function [] = demo_densityestimation_cv(num_fold)

addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');
%addpath('kde/gmm');
randn('state', 1);
rand('twister', 1);    

%heads = { 'spiral2', 'iris', 'glass', 'wine', 'vowel200', 'vehicle200',...
%    'segment200', 'satimage200', 'letter200', 'mnist200'};
%heads = { 'spiral2', 'iris', 'glass', 'wine', 'vowel' };
%heads = { 'iris', 'vowel' };

%heads = {'wine'};
%heads = {'vowel'};

%heads = {'halfcircles_N50K3'};
heads = {'halfcircles_N100K3'};
%heads = {'circles_N50K2'};
%heads = {'pinwheel_N50K5'};


heads = {'spiral2','halfcircles_N100K3','circles_N50K2','pinwheel_N50K5'};
heads = { 'iris', 'glass', 'wine'};
heads = {'vowel'};
heads = {'spiral2'};

heads = {'spiral2','circles_N50K2','pinwheel_N50K5'};
heads = {'iris'};
%heads = {'glass'};
%heads = {'wine'};
%heads = {'vowel'};
heads = {'halfcircles2_N100K3'};

%data_iters = 2;
data_iters = num_fold;

%maxNumCompThreads(10);

for i = 1:numel(heads);
    
    fn = sprintf('data/%s.mat',heads{i})
    load(fn);
    [~,observed_dimension] = size(X);
    
    latent_dimensions = {2,observed_dimension};
    if observed_dimension == 2
        latent_dimensions = {2};
    end
    
    rfn = sprintf('results_cv%d/densityestimation_cv_%s.txt',data_iters, heads{i});
    fid = fopen(rfn,'w');

    %parfor k = 1:data_iters
    for k = 1:data_iters
        %infinite GMM
        ofn = sprintf('results_cv%d/result_cv_gmm_%s_%d.mat',data_iters, heads{i},k);
        S = load(ofn);
        [gmm_logps] = test_probability_gmm(S.hist_post,S.trainX,S.testX);
        disp('iGMM');
        disp(mean(gmm_logps));
        
        %KDE
        [kde_logps,~] = kde(S.trainX,S.testX);
        disp('KDE');
        disp(mean(kde_logps));

        %MPW
        %num_eigs= 2; num_neighbors = 5; 
        %[~,mpw_logps,~] = mpar(S.trainX',S.testX',num_eigs,num_neighbors);
        %mean(mpw_logps)
        
        %DP&GPLVM (iWMM)
        N = size(S.testX,1);
        dpgp_logps = zeros(N,numel(latent_dimensions));
        disp('iWMM');
        for j = 1:numel(latent_dimensions)
            ofn = sprintf('results_cv%d/result_cv_iwmm_%s_%d_%d.mat',data_iters, heads{i},latent_dimensions{j},k);
            S = load(ofn);
            [dpgp_logps(:,j)] = test_probability(S.hist_params,S.hist_post,S.trainX,S.testX);
            disp(mean(dpgp_logps(:,j)));
        end
        
        %GPLVM (WM)
        disp('WM');
        gp_logps = zeros(N,numel(latent_dimensions));
        for j = 1:numel(latent_dimensions)
            ofn = sprintf('results_cv%d/result_cv_wm_%s_%d_%d.mat',data_iters, heads{i},latent_dimensions{j},k);
            S = load(ofn);
            [gp_logps(:,j)] = test_probability(S.hist_params,S.hist_post,S.trainX,S.testX);
            disp(mean(gp_logps(:,j)));
        end

        if numel(latent_dimensions) == 2
            fprintf( fid, '%f %f %f %f %f %f\n', mean(kde_logps),...
                mean(gmm_logps),...
                mean(gp_logps(:,1)),mean(gp_logps(:,2)),...
                mean(dpgp_logps(:,1)),mean(dpgp_logps(:,2)));

        else
            fprintf( fid, '%f %f %f %f %f %f\n', mean(kde_logps),...
                mean(gmm_logps),...
                mean(gp_logps),mean(gp_logps),...
                mean(dpgp_logps),mean(dpgp_logps));
        end
    end
    fclose(fid);
end
