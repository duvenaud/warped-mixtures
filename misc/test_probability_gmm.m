function [logpy] = test_probability_gmm( hist_post, Y, Ystar )

addpath('util');
close all;

randn('state', 1);
rand('twister', 1);    

num_iters = numel(hist_post);
%samplenum = 1;
samplenum = 1000;
if samplenum > num_iters
    samplenum = floor(num_iters/2);
end
%samplenum = 1;

[N,input_dimension]=size(Y);
Nstar = size(Ystar,1);
py = zeros(Nstar,1);
cnt = 0;
start = num_iters-samplenum+1;
for i = start:num_iters
    n_components = numel(hist_post(i).ns);
    p = 0.0;
    for j = 1:n_components
        mix = hist_post(i).ns(j)/N;
        S = hist_post(i).Chols(:,:,j)'*hist_post(i).Chols(:,:,j);
        Sigma = S/hist_post(i).nus(j);
        p = p + mix*mvnpdf(Ystar,hist_post(i).ms(j,:),Sigma);
    end
    py = py + p;
    cnt = cnt+1;
    pys(:,cnt) = py./cnt;
    %if mod(i,100) == 0
    %    plot(pys');
    %    drawnow;
    %end
end
py = py/cnt;
logpy = log(py);