function [logpy] = test_probability( hist_params, hist_post, Y, Ystar )

addpath('util');
addpath('gpml/cov');
addpath('gpml/util');
close all;

randn('state', 1);
rand('twister', 1);    

num_iters = numel(hist_params);
samplenum = 1000;
if samplenum > num_iters
    samplenum = floor(num_iters/2);
end
%samplenum = 1;

[N,input_dimension]=size(Y);
Nstar = size(Ystar,1);
py = zeros(Nstar,1);
cnt = 0;
n_points = 100;
start = num_iters-samplenum+1;
for i = start:num_iters
    [Xdist,~] = mixnormwishrnd(hist_post(i),n_points);

    hyp(1) = -hist_params(i).log_hypers.gamma/2;
    hyp(2) = hist_params(i).log_hypers.alpha/2;
    Kc2 = covSEiso(hyp, Xdist, hist_params(i).X);
    K = covSEiso(hyp, hist_params(i).X);
    K = K + eye(N)*max(exp(hist_params(i).log_hypers.betainv), 1e-3);  % HACK
    
    invK = inv(K);
    mus = Kc2*invK*Y;    
    input_dimension = size(mus,2);
    for j = 1:n_points
        Kstar = covSEiso(hyp,Xdist(j,:));
        Kstar = Kstar+max(exp(hist_params(i).log_hypers.betainv), 1e-3);
        s = Kstar-Kc2(j,:)*invK*Kc2(j,:)';
        p = mvnpdf(Ystar,mus(j,:),s*eye(input_dimension));
        py = py+p;
        cnt = cnt+1;
        pys(:,cnt) = py./cnt;
        %if mod(j,100) == 0
        %    plot(pys');
        %    drawnow;
        %end
    end
end
logpy = log(py/(n_points*samplenum));
