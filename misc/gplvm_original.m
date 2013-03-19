function [ params ] = gplvm_original(Y,Q,options)

% Q is the dimension of the latent space.

addpath('minFunc');

[N,D] = size(Y) ;

%centering
Y = Y - repmat( mean( Y, 1 ), N, 1 ) ;

%initalize X by pca
if D==Q
    params.X = Y;
else
    [svd1,~,~] = svd( Y, 0 ) ;
    params.X = svd1( :, 1:Q ) ;
end

%initialize X randomly
%X0 = normrnd( 0, 0.1, N, Q ) ;

params.log_hypers.alpha = 0;
params.log_hypers.betainv = 0;
params.log_hypers.gamma = 0;

options.useMex = 0;
if ~isfield(options,'maxFunEvals')
    options.maxFunEvals = 100;
end
options.Display = 'off';

unwrapped_params = unwrap( params );
%checkgrad('gplvm_original_likelihood', unwrapped_params, 1e-6, Y, params);
[unwrapped_params] = minFunc(@gplvm_original_likelihood,...
    unwrapped_params, options, Y, params);
params = rewrap( params, unwrapped_params );
end