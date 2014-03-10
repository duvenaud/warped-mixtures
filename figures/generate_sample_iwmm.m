function [] = generate_sample_iwmm(seed, num_points, draw_fast, gplvm, savefigs)
%
% Code to generate a nice figure of a draw from a warped mixture prior.
%
% David Duvenaud
% Tomoharu Iwata

addpath('../util');
addpath('../misc');
addpath('../gpml/cov');
addpath('../gpml/util');

if nargin < 1; seed = randi(10000); end
if nargin < 2; num_points = 100; end
if nargin < 3; draw_fast = true; end
if nargin < 4; gplvm = false; end
if nargin < 5; savefigs = false; end

%seed=869; %seed=594; %seed=216; %seed=914;
randn('state',seed);
rand('state',seed);

Q = 2;
D = 2;

figsize_cm = 15;

% Draw assignments from a Chinese restaurant process.
if gplvm
    eta = 0;
else
    eta = 1;
end

assignments(1) = 1;
for n = 2:num_points
    prob = [];
    for k = 1:max(assignments)
        prob = [prob,sum(assignments==k)];
    end
    prob = [prob,eta];
    prob = prob/sum(prob);
    assignments(n) = find(mnrnd(1,prob));
end

num_components = max(assignments);

% Renormalize cluster weights to one.
lambda = histc(assignments, 1:num_components)./num_points;


% Gaussian parameter generation
r = 0.05;
nu = Q+5;
S = eye(Q);
invS = inv(S);
u = zeros(1,Q);

% Generate random covariance matrices.
mix = [];
for c = 1:num_components
    if gplvm == 1
        R(:,:,c) = eye(Q);
        mix.mus(c,:) = zeros(Q,1);
    else
        R(:,:,c) = wishrnd(invS,nu);
        mix.mus(c,:) = mvnrnd(u,inv(r*R(:,:,c)));
    end
    mix.decomps(:,:,c) = chol(R(:,:,c));
    invR(:,:,c) = inv(R(:,:,c));
end
mix.weights = lambda;

%%% latent point generation
for n = 1:num_points
    x(n,:) = mvnrnd(mix.mus(assignments(n),:),invR(:,:,assignments(n)));
end

assignments01 = zeros(num_points,num_components);
for n = 1:num_points
    assignments01(n,assignments(n)) = 1;
end
mix.weights = mix.weights / 4; % For transparent contours.

figure(1); clf;
draw_latent_representation(x, mix, assignments01, assignments);
mix.weights = mix.weights * 4;
axis off;
set_fig_units_cm(figsize_cm, figsize_cm);

%tightfig;
if savefigs
    myaa('publish')
    filename = sprintf('gplvm-latent-n-%d-seed%d',num_points, seed);
    savepng(gcf, filename);
end


% Generate observed points by warping the latent points.
log_hypers.alpha = 0;

embedding_noise = 0.0001;
embedding_lengthscale = 2;

log_hypers.gamma = -2*log(embedding_lengthscale);
log_hypers.betainv = 2*log(embedding_noise);

covfunc = @covSEiso;
hyp(1) = -log_hypers.gamma/2;
hyp(2) = log_hypers.alpha/2;
K = covfunc(hyp, x);
K = K + eye(num_points)*exp(log_hypers.betainv);

Y = NaN(num_points,D);
for d = 1:D
    Y(:,d) = mvnrnd(zeros(num_points,1),K,1);
end

if draw_fast == false
    circle_size = 0.03;
    circle_alpha = 0.05;
    num_colored_dots = 100000;
else
    circle_size = 0.1;
    circle_alpha = 0.1;
    num_colored_dots = 1000;
end

figure(2); clf;
draw_gpmapping_mixgauss( x, Y, mix, log_hypers, assignments01, assignments, ...
                         circle_size, circle_alpha, num_colored_dots);

axis off;
set(gcf, 'color', 'white');
set_fig_units_cm(figsize_cm, figsize_cm);
%tightfig;

if savefigs
    myaa('publish')
    filename = sprintf('gplvm-observed-n-%d-seed%d',num_points, seed);
    savepng(gcf, filename);
end
end
