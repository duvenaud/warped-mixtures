function [ f, grad_X, log_hypers_grad ] = gplvm_likelihood( X, Y, log_hypers )
    % Returns the likelihood of the GP-LVM, along with 
    % derivatives w.r.t. X and kernel hyperparameters.
    
    [N, observed_dimension] = size(Y);
    [latent_dimension] = size(X, 2);
    
    % Compute kernel matrix in-place (squared exponential kernel function).
    K1 = X * X' ;
    Dia = diag(K1) ;
    K1 = K1 - ones(N,1) * Dia' / 2 ;
    K1 = K1 - Dia * ones(1,N) / 2 ;
    K1 = exp(log_hypers.gamma) * K1 ;
    
    K2 = exp(log_hypers.alpha + K1) ;
    K = K2 + eye(N)*max(exp(log_hypers.betainv), 1e-3);  % HACK

    %{
    hyp(1) = -log_hypers.gamma/2;
    hyp(2) = log_hypers.alpha/2;
    K2 = covSEiso(hyp, X);
    %K = K2 + eye(N)*min(max(exp(log_hypers.betainv),1e-6),1e+3);  % HACK
    K = K2 + eye(N)*max(exp(log_hypers.betainv), 1e-3);  % HACK
    %}

    
    % Calculate objective function (negative log likelihood)
    tmp = (K \ Y) * Y';
    gradLK = 0.5 .* (tmp - observed_dimension * eye(N)) / K;
    f = 0.5 * observed_dimension * logdet(K) + 0.5 * trace(tmp) ;

    grad_X = zeros( N, latent_dimension ) ;
    for n1 = 1:N
        %grad_X(n1,:) = -gradLK(n1, :)*( -2*exp(log_hypers.gamma)* ...
        %                (repmat(X(n1,:),N,1) - X) .* ...
        %                repmat(K(:,n1),1,latent_dimension)) ;
        
        %grad_X(n1,:) = -gradLK(n1, :)*((repmat(X(n1,:),N,1) - X) .* ...
        %                repmat(K(:,n1),1,latent_dimension)) ;        
        xn = X(n1,:);
        Kn = K(:,n1);
        grad_X(n1,:) = -gradLK(n1, :)*((xn(ones(N,1),:)-X).*...
                        Kn(:,ones(1,latent_dimension)));
    end
    grad_X = grad_X * -2*exp(log_hypers.gamma);
    log_hypers_grad.alpha = -sum(sum(gradLK.*K2));
    log_hypers_grad.betainv = -exp(log_hypers.betainv) * trace(gradLK) ;
    log_hypers_grad.gamma  = -sum(sum(gradLK.*(K1.*K2)));

    %gradLa=0; gradLb=0; gradLg=0; % no kernel parameter update
end
