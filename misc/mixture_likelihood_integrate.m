function [ nll, dnll_X ] = mixture_likelihood_integrate( X, resp, prior )
    % Computes the gradient of the expected complete neg log likelihood w.r.t. X
    % Responsibilites have been pre-computed.
    
    [N, latent_dimension] = size(X);
    [n_components] = size(resp, 2);

    prior.r = 1;
    prior.nu = 1;
    prior.S = eye(latent_dimension);
    prior.m = zeros(1,latent_dimension);
    
    nll = 0;
    dnll_X = zeros( N, latent_dimension ) ;        
    for z = 1:n_components
        n = sum(resp(:,z),1);
        Xz = X(find(resp(:,z)==1),:);
        C = Xz'*Xz;
        rprime = prior.r+n;
        nuprime = prior.nu+n;
        mprime = (prior.r*prior.m+sum(Xz,1))/(prior.r+n);
        Sprime = prior.S+C+prior.r*(prior.m'*prior.m)-rprime*(mprime'*mprime);
        L = 0.5*nuprime*logdet( Sprime );
        nll = nll+L;
        
        invSprime = inv(Sprime);
        dnll_X(find(resp(:,z)==1),:) = dnll_X(find(resp(:,z)==1),:)...
           +nuprime*(Xz-repmat(rprime/(prior.r+n).^2*(prior.r*prior.m+sum(Xz)),n,1))*invSprime;
    end
end 
