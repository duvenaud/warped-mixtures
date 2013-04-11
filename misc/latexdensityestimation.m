clear results;
heads = {'spiral2','halfcircles2_N100K3','circles_N50K2', ...
         'pinwheel_N50K5','iris', 'glass', 'wine','vowel'};
%heads = {'spiral2','circles_N50K2', ...
%         'pinwheel_N50K5','iris', 'glass', 'wine','vowel'};
%heads = {'spiral2'};
fold_num = 20;

for i = 1:numel(heads)
  fn = sprintf('results_cv%d/densityestimation_cv_%s.txt',num_fold,heads{i});
  results(:,:,i) = load(fn);
end

resultsToLatex('densityestimation2.tex',results,{'KDE','iGMM','WM(Q=2)','WM(Q=D)','iWMM(Q=2)','iWMM(Q=D)'},...
heads,'log likelihood',0,0,0)

results(:,3:4,:) = [];  

resultsToLatex('densityestimation.tex',results,{'KDE','iGMM','iWMM(Q=2)','iWMM(Q=D)'},...
heads,'log likelihood',0,0,0)

