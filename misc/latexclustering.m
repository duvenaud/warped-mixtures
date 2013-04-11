clear results;
%heads = {'spiral2','halfcircles_N100K3','circles_N50K2', ...
%         'pinwheel_N50K5','iris', 'glass', 'wine','vowel'};
%heads = {'spiral2'};
heads = {'spiral2','iris', 'glass', 'wine'};
heads = {'spiral2','halfcircles2_N100K3','circles_N50K2', ...
         'pinwheel_N50K5','iris', 'glass', 'wine','vowel'};
%fold_num = 20;

for i = 1:numel(heads)
  fn = sprintf('results_cv%d/clustering_cv_%s.txt',num_fold,heads{i});
  results(:,:,i) = load(fn)
end

resultsToLatex4('clustering.tex',results,{'iGMM','iWMM(Q=2)','iWMM(Q=D)'},...
heads,'rand index',0)


fold_num = 20;

for i = 1:numel(heads)
  fn = sprintf('results_cv%d/clustering_cv_%s.txt',num_fold,heads{i});
  results(:,:,i) = load(fn)
end

resultsToLatex('clustering.tex',results,{'iGMM','iWMM(Q=2)','iWMM(Q=D)'},...
heads,'rand index',0,0,0)

