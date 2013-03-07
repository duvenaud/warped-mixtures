function [] = demo_coassignment


%heads = {'iris','glass','wine','vowel'};
%heads = {'glass','wine','iris','vowel'};
%heads = {'iris'};
%heads = {'glass','wine','iris','vowel'};
heads = {'spiral2_2_1',...
    'halfcircles2_N100K3_2_1',...
    'circles_N50K2_2_1',...
    'pinwheel_N50K5_2_1',...
    'iris_4_1',...
    'glass_9_1',...
    'wine_13_1',...
    'vowel_10_1'};

heads = {'spiral2',...
    'halfcircles2_N100K3',...
    'circles_N50K2',...
    'pinwheel_N50K5',...
    'iris',...
    'glass',...
    'wine'}
    %'vowel'};
    
Qs = [2,2,2,2,4,9,13,10];
sample_num = 1000;
for i = 1:numel(heads)
    heads(i)

    fn = sprintf('/work/ti242/results_cv1/result_cv_iwmm_%s_%d_1.mat',heads{i},Qs(i));
    load(fn);
    n_samples = numel(hist_assignments);
    start = n_samples-sample_num+1;
    eca = average_coassignment(hist_assignments(start:n_samples));
    figure(123); imagesc(eca);
    efn = sprintf('figures/coassignment_iwmm_%s.eps',heads{i});
    print('-depsc',efn);

    fn = sprintf('/work/ti242/results_cv1/result_cv_gmm_%s_1.mat',heads{i});
    load(fn);
    n_samples = numel(hist_assignments);
    start = n_samples-sample_num+1;
    eca = average_coassignment(hist_assignments(start:n_samples));
    figure(123); imagesc(eca);
    efn = sprintf('figures/coassignment_gmm_%s.eps',heads{i});
    print('-depsc',efn);    
end