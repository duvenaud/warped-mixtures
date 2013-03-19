function [] = demo_clustering_cv

addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');
%addpath('spcluster');

randn('state', 1);
rand('twister', 1);    

%heads = { 'spiral2', 'iris', 'glass', 'wine', 'vowel200', 'vehicle200',...
%    'segment200', 'satimage200', 'letter200', 'mnist200'};
%heads = {'spiral2'};
%heads = { 'spiral2', 'iris', 'glass', 'wine', 'vowel' }
%heads = { 'wine', 'vowel' };
heads = {'spiral2'};
%heads = {'glass'};
%heads = {'halfcircles_N50K3'};
%heads = {'halfcircles_N100K3'};
%heads = {'circles_N50K2'};
%heads = {'pinwheel_N50K5'};

%heads = {'halfcircles_N50K3','circles_N50K2','pinwheel_N50K5'};

%heads = {'spiral2','halfcircles_N100K3','circles_N50K2', ...
%         'pinwheel_N50K5','iris', 'glass', 'wine','vowel'};

heads = {'spiral2','halfcircles2_N100K3','circles_N50K2', ...
         'pinwheel_N50K5','iris', 'glass', 'wine','vowel'};

heads = {'spiral2','circles_N50K2', ...
         'pinwheel_N50K5','iris', 'glass', 'wine'};
heads = {'vowel'};
heads = {'halfcircles2_N100K3'};

%data_iters = 10;
data_iters = 20;

for i = 1:numel(heads);
    fn = sprintf('data/%s.mat',heads{i})
    load(fn);
    [~,observed_dimension] = size(X);
    
    latent_dimensions = {2,observed_dimension};
    if observed_dimension == 2
        latent_dimensions = {2};
    end
        
    rfn = sprintf('results_cv%d/clustering_cv_%s.txt',data_iters,heads{i})
    fid = fopen(rfn,'w');
    
    for k = 1:data_iters
    %infinite GMM
        ofn = sprintf('results_cv%d/result_cv_gmm_%s_%d.mat',data_iters,heads{i},k);
        if ~exist(ofn)
            continue;
        end
        load(ofn);
        
        ansy = trainy;
        [sy1,sy2] = size(ansy);
        if sy1 < sy2 
            ansy = ansy';
        end
     
        [tmp,esty] = find(hist_assignments{end});
        [~,idx] = sort(tmp);
        gmm_ri = randindex(ansy,esty(idx));
    
        n_classes = max(trainy);

        %{
        %k-means
        [kmeans_y] = kmeans(trainX,n_classes);
        kmeans_ri = randindex(ansy,kmeans_y);
    
        %affinity propagation
        [ap_y] = affiprop(trainX);
        ap_ri = randindex(ansy,ap_y);
    
        %self-tuning spectracl clustering
        [sp_y] = spcluster(trainX);
        sp_ri = randindex(ansy,sp_y);
        %}
    
        %DP&GPLVM
        for j = 1:numel(latent_dimensions)
            ofn = sprintf('results_cv%d/result_cv_iwmm_%s_%d_%d.mat', ...
                          data_iters,heads{i},latent_dimensions{j},k);
            load(ofn);
            [tmp,esty] = find(hist_assignments{end});
            [~,idx] = sort(tmp);
            dpgp_ri(j) = randindex(ansy,esty(idx));
        end
        
        %fprintf( '%s %.3f %.3f %.3f %.3f\n', heads{i}, kmeans_ri, ap_ri,
        %sp_ri, gmm_ri );
        display('iGMM');
        display( gmm_ri );
        display('iWMM');
        display( dpgp_ri );

        if numel(latent_dimensions) == 2
            fprintf( fid, '%f %f %f\n',gmm_ri,dpgp_ri(1),dpgp_ri(2));
        else
            fprintf( fid, '%f %f %f\n',gmm_ri,dpgp_ri,dpgp_ri);
        end
    end
    fclose(fid);    

    %ofn = sprintf('results_cv%d/result_test_randindex_%s.mat',data_iters,heads{i});
    %save( ofn, 'kmeans_ri', 'dpgp_ri', 'gmm_ri' );
    %fprintf( '%s %.3f %.3f %.3f\n', heads{i}, kmeans_ri, ap_ri, sp_ri );
end
