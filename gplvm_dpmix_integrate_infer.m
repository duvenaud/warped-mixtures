%function [ X, post, hypers ] = ...
function [ hist_post, hist_params, nll, hist_assignments, arate, F ] =...
    gplvm_dpmix_integrate_infer( latent_dimension, n_components, Y, labels, options )
% GP-LVM with mixture of Gaussians latent p(X).
%
% latent_dimension is the dimension of the latent space.
% n_components is the number of mixture components.
% Y is the observed data.
%
% labels is an integer starting at 1 for the observed class label,
% and NaN for unobserved.
%
% This version generates samples from the posterior instead of 
% maximizing likelihood.  It works by alternatively sampling p(c|x) and p(x|c).
%
% Tomo and David
% April 2012

tic;

if nargin < 4; labels = []; end
%if nargin < 5; options = {}; end

%addpath('minFunc');
addpath('nutsmatlab');

[N,input_dimension] = size(Y);

num_iters = 10000;

% options for hybrid monte calro
hmc_options.num_iters = 1;
hmc_options.Tau = 25;
hmc_options.epsilon = 0.001 * sqrt(N);
hmc_options.isPlot = 0;

isDP = 1;
isGP = 1;
isSamplingDPparameter = 0;
isPlot = 1;
isFixedGauss = 0;
isGPLVMinit = 0;
isMovie = 0;
prior_r = 1;
prior_alpha = 1;
if isfield( options, 'prior_r' )
    prior_r = options.prior_r;
end
if isfield( options, 'prior_alpha' )
    prior_alpha = options.prior_alpha;
end
if isfield( options, 'isMovie' )
    isMovie = options.isMovie;
end
if isfield( options, 'isPlot' )
    isPlot = options.isPlot;
end
if isfield( options, 'isFixedGauss')
    isFixedGauss = options.isFixedGauss;
end
if isfield( options, 'isDP' )
    isDP = options.isDP;
end
if isfield( options, 'isSamplingDPparameter' )
    isSamplingDPparameter = options.isSamplingDPparameter ;
end
if isfield( options, 'num_iters' )
    num_iters = options.num_iters;
end
if isfield( options, 'epsilon' )
    hmc_options.epsilon = options.epsilon;
end
if isfield( options, 'Tau' )
    hmc_options.Tau = options.Tau;
end
if isfield( options, 'hmc_isPlot' )
    hmc_options.isPlot = options.hmc_isPlot;
end
if isfield( options, 'no_warp' )
    hmc_options.epsilon = options.no_warp;
end
if isfield( options, 'isGP' )
    isGP = options.isGP;
end
if isfield( options, 'isGPLVMinit' )
    isGPLVMinit = options.isGPLVMinit;
end
if isfield( options, 'isback' )
    hmc_options.isback = options.isback;
end

% Centering
%Y = Y-repmat(mean(Y,1),N,1);

% Initalize X as same as the observed data Y
if isGP == 0
    latent_dimension = input_dimension;
end
if latent_dimension == input_dimension
    init_X = Y;
elseif isGPLVMinit == 1
    gplvm_options = [];
    gplvm_params = gplvm_original(Y,latent_dimension,gplvm_options);
    init_X = gplvm_params.X;
elseif latent_dimension <= input_dimension
    init_X = Y(:,1:latent_dimension);
else
    init_X(:,1:input_dimension) = Y;
    init_X(:,input_dimension+1:end) = 0;
end
if sum(sum(init_X)) == 0
    init_X = init_X + randn(N,latent_dimension);
end

% Initialize kernel hyperparameters.
log_hypers.alpha = -1;
log_hypers.betainv = -1;
log_hypers.gamma = -1;

% Set priors for Gaussian-Wishart
prior.r = prior_r;
prior.nu = latent_dimension;
prior.S = eye(latent_dimension);
prior.m = zeros(1,latent_dimension);
prior.Chol = cholcov(prior.S);

% Dirichlet prior
prior.alpha = prior_alpha;
% Dirichlet parameter prior
prior.a = 1;
prior.b = 1;

if n_components == 0 %sequential initalization
    n_components = 1;
    assignments = zeros(N,1);
    assignments(1,1) = 1;
else
% initialize assigments with kmeans
    assignments = zeros(N,n_components);
    cidx = kmeans(init_X,n_components,'emptyaction','singleton');
    for z = 1:n_components
        assignments(cidx==z,z) = 1;
    end
end

% initialize posteriors
post.ns = NaN(n_components,1);
post.rs = NaN(n_components,1);
post.nus = NaN(n_components,1);
post.ms = NaN(n_components,latent_dimension);
post.Chols = NaN(latent_dimension,latent_dimension,n_components);
post.alphas = NaN(n_components,1);

% Put all the parameters that will be optimized into a struct.
params.X = init_X;
params.log_hypers = log_hypers;

global gammaterm_n;
gammaterm_n = NaN(N,1);

arate = 0;
arate_cnt = 0;
arate_start = 100;

%hist_assignments = NaN;

% Main inference loop
for i = 1:num_iters
    % Calculate posteriors for Gaussian-Wishart hyper-parameters.
    % (integrate out means and covariances of latent Gaussians, exactly).
    if isFixedGauss == 0
        for z = 1:n_components
            post.ns(z) = sum(assignments(:,z),1);
            post.alpha(z) = prior.alpha+post.ns(z);
            post.rs(z) = prior.r+post.ns(z);
            post.nus(z) = prior.nu+post.ns(z);
            if post.ns(z) > 0
                Xz = params.X(assignments(:,z)==1,:);
                post.ms(z,:) = (prior.r*prior.m+sum(Xz,1))/(prior.r+post.ns(z));
                S = prior.S+Xz'*Xz+prior.r*(prior.m'*prior.m)-post.rs(z)*(post.ms(z,:)'*post.ms(z,:));
                post.Chols(:,:,z) = cholcov(S);
            else
                % Store covariances in Cholesky form.
                post.ms(z,:) = prior.m;
                post.Chols(:,:,z) = cholcov(prior.S);
            end
        end
        
        % Sampling cluster assignments conditioned on x locations.
        if isDP == 1
            [L,assignments,post] = gaussian_dpmixture_gibbsstep(params.X,assignments,prior,post);
        else
            [L,assignments,post] = gaussian_mixture_gibbsstep(params.X,assignments,prior,post);
        end
        hist_assignments{i} = assignments ;
        
        n_components = size(assignments,2);
        Ls(i) = L;
        
        Ks(i) = numel(find(sum(assignments,1)>0));
        
        if isSamplingDPparameter == 1
            prior.alpha = sampling_dphyperparameter(prior.alpha,N,n_components,...
                prior.a,prior.b);
        end
    else
        Ls(i) = 0;
        Ks(i) = 1;
        hist_assignments{i} = NaN;
    end
    
    
    % Sampling X and GP-LVM hypers given cluster assignments
    % using Hamiltonian Monte Carlo
    % ==================================================

    if isGP == 1
        % Convert structure of parameters into a vector.
        unwrapped_params = unwrap( params );
        try
            if isFixedGauss == 0
                %checkgrad('joint_likelihood_integrate',...
                %    unwrapped_params, 1e-6, ...
                %    Y, assignments, params, prior );
                [unwrapped_params, nll(i), arate0] = hmc(@joint_likelihood_integrate, unwrapped_params, ...
                    hmc_options, labels, Y, assignments, params, prior );
                if i > arate_start
                    arate = arate+arate0;
                    arate_cnt = arate_cnt+1;
                end
                %disp(arate/i);
                %[unwrapped_params] = nuts_da(@joint_likelihood_integrate,1,100,unwrapped_params',0.6,Y,assignments,params,prior);
                %nll(i) = joint_likelihood_integrate(unwrapped_params,Y,assignments,params,prior);
                %minfunc_options = [];
                %minfunc_options.useMex = 0;
                %[unwrapped_params, nll(i)] = minFunc(@joint_likelihood_integrate, unwrapped_params, ...
                %    minfunc_options, Y, assignments, params, prior );                
            else
                %checkgrad('joint_likelihood_fixedgaussian',...
                %    unwrapped_params, 1e-6, ...
                %    Y, assignments, params, prior );
                [unwrapped_params, nll(i)] = hmc(@joint_likelihood_fixedgaussian, unwrapped_params, ...
                    hmc_options, labels, Y, assignments, params, prior );
            end
        catch
            nll(i) = NaN;
            unwrapped_params = unwrap( params );
            fprintf('R');
            %hmc_options.eplison = hmc_options.epsilon / 2;
        end
        % Re-pack parameters.
        params = rewrap( params, unwrapped_params );
    else
        nll(i) = -L;
    end
    
   % save GPLVM params
    run_hypers_alpha(i) = exp( params.log_hypers.alpha ) ;
    run_hypers_inv_beta(i) = exp( params.log_hypers.betainv ) ;
    run_hypers_gamma(i) = exp( params.log_hypers.gamma ) ;   

    %save normal-Wishart posteriors and GPLVM parameters
    hist_post(i) = post;
    hist_params(i) = params;
    
    %drawing
    if isMovie == 1
        if isFixedGauss == 0
            mix.weights = (post.ns)./sum(post.ns);
            mix.mus = post.ms;
            for z = 1:n_components
                C = chol(inv(post.Chols(:,:,z)'*post.Chols(:,:,z)));
                mix.decomps(:,:,z) = sqrt(post.nus(z))*C;
            end
        else
            mix.weights = 1;
            mix.mus = zeros(1,latent_dimension);
            mix.decomps = eye(latent_dimension);
        end
        
        % Draw the current mixture parameters, along with the latent positions.
        if numel(labels) > 0
            draw_latent_representation( params.X, mix, assignments, labels );
            axis( [-7 5 -5 7]);
            drawnow;
            F(i) = getframe;
        end
    end
    
    if isPlot ~= 0
        if mod(i,isPlot) == 0 || i == num_iters
            if isFixedGauss == 0
                mix.weights = (post.ns)./sum(post.ns);
                mix.mus = post.ms;
                for z = 1:n_components
                    C = chol(inv(post.Chols(:,:,z)'*post.Chols(:,:,z)));
                    mix.decomps(:,:,z) = sqrt(post.nus(z))*C;
                end
            else
                mix.weights = 1;
                mix.mus = zeros(1,latent_dimension);
                mix.decomps = eye(latent_dimension);
            end
            
            % Draw the current mixture parameters, along with the latent positions.
            if numel(labels) > 0
                draw_latent_representation( params.X, mix, assignments, labels );
            else
                draw_latent_representation( params.X, mix, assignments );
            end
            
            if isGP == 1 && input_dimension == 2
                % Draw the original data and current assigments
                draw_gpmapping_mixgauss( params.X, Y, mix, params.log_hypers,...
                    assignments, labels );
            end
            
            figure(532130); clf;
            plot(Ks,'b-');
            ylabel('number of clusters');
            
            % Sanity check
%            if isGP == 1
                figure(123); clf;
                plot( nll, 'b-' );
                ylabel('negative log likelihood');
%            else
%                figure(123); clf;
%                plot( Ls, 'b-' );
%                ylabel('log likelihood');
%            end
            % Plot hypers over time
            figure(123423); clf;
            plot( run_hypers_alpha, 'b-' ); hold on;
            plot( run_hypers_inv_beta, 'r-' ); hold on;
            plot( 1./run_hypers_gamma, 'g-' ); hold on;
            legend({'a (output variance)', '1/b (noise level)', '1/g (lengthscale squared)'});
            title('hyperparams');
            
            drawnow;
        end
    end
end

arate = arate/arate_cnt;

% Pack things up to return them.
%hypers.alpha = exp( params.log_hypers.alpha ) ;
%hypers.beta = 1 / exp( params.log_hypers.betainv ) ;
%hypers.gamma = exp( params.log_hypers.gamma ) ;
%X = params.X;
toc;
end
