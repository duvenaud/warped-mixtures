function [L,assignments,post] = gaussian_mixture_gibbsstep(X,assignments,prior,post)

% post: posteriors

[N,dim] = size(X);
n_components = size(assignments,2);

for n = 1:N
    cur_z = find(assignments(n,:));
    
    % omit the current sample
    assignments(n,:) = zeros(1,n_components);
    post.Chols(:,:,cur_z) = cholupdate(post.Chols(:,:,cur_z),...
                             sqrt(post.rs(cur_z))*post.ms(cur_z,:)','+');
    post.ms(cur_z,:) = post.ms(cur_z,:)*(prior.r+post.ns(cur_z))-X(n,:);
    post.ns(cur_z) = post.ns(cur_z)-1;
    post.rs(cur_z) = post.rs(cur_z)-1;
    post.nus(cur_z) = post.nus(cur_z)-1;
    post.ms(cur_z,:) = post.ms(cur_z,:)/(prior.r+post.ns(cur_z));
    post.Chols(:,:,cur_z) = cholupdate(post.Chols(:,:,cur_z),X(n,:)','-');
    post.Chols(:,:,cur_z) = cholupdate(post.Chols(:,:,cur_z),sqrt(post.rs(cur_z))*post.ms(cur_z,:)','-');

    % Dirichlet-multinomial part
    prob = log(sum(assignments,1)+prior.alpha);
    
    % Gaussian-Wishart part
    for z = 1:n_components

        % calculate posteriors when sample n is assigned to z
        Chol = cholupdate(post.Chols(:,:,z),sqrt(post.rs(z))*post.ms(z,:)','+');
        m = post.ms(z,:)*(prior.r+post.ns(z))+X(n,:);
        num = post.ns(z)+1;
        r = post.rs(z)+1;
        nu = post.nus(z)+1;
        m = m/(prior.r+num);
        Chol = cholupdate(Chol,X(n,:)','+');
        Chol = cholupdate(Chol,sqrt(r)*m','-');
        
        prob(z) = prob(z) + loglikelihood(dim,...
            post.ns(z),post.rs(z),post.nus(z),post.Chols(:,:,z),...
            num,r,nu,Chol);
    end
    % normalize so as to sum to one
    prob = exp(prob-repmat(logsumexp(prob,2),1,n_components));

    % sampling assignment
    assignments(n,:) = mnrnd(1,[prob(1:end-1),1-sum(prob(1:end-1))]);
    if isnan(assignments(n, :)) % FIXME
        assignments(n,:) = zeros(1,n_components);
        [~,maxind]=max(prob);
        assignments(n,maxind) = 1;
    end
    
    % update the hyperparameters according to sampled assignment
    cur_z = find(assignments(n,:));
    post.Chols(:,:,cur_z) = cholupdate(post.Chols(:,:,cur_z),sqrt(post.rs(cur_z))*post.ms(cur_z,:)','+');
    post.ms(cur_z,:) = post.ms(cur_z,:)*(prior.r+post.ns(cur_z))+X(n,:);
    post.ns(cur_z) = post.ns(cur_z)+1;
    post.rs(cur_z) = post.rs(cur_z)+1;
    post.nus(cur_z) = post.nus(cur_z)+1;
    post.ms(cur_z,:) = post.ms(cur_z,:)/(prior.r+post.ns(cur_z));
    post.Chols(:,:,cur_z) = cholupdate(post.Chols(:,:,cur_z),X(n,:)','+');
    post.Chols(:,:,cur_z) = cholupdate(post.Chols(:,:,cur_z),sqrt(post.rs(cur_z))*post.ms(cur_z,:)','-');    

    % check updates
    %{
    for z = 1:n_components    
        fprintf('---------------\n');
        Xz = X(find(assignments(:,z)==1),:);
        post.ms(z,:)
        (prior.r*prior.m+sum(Xz,1))/(prior.r+post.ns(z))
        S = prior.S+Xz'*Xz+prior.r*(prior.m'*prior.m)-post.rs(z)*(post.ms(z,:)'*post.ms(z,:));
        post.Chols(:,:,z)
        cholcov(S)
    end
    %}

end

L = 0;
% likelihood for Dirichlet-Multinomial
L = L+gammaln(prior.alpha*n_components);
L = L-n_components*gammaln(prior.alpha);
L = L+sum(gammaln(post.ns+prior.alpha));
L = L-gammaln(N+prior.alpha*n_components);
% likelihood for Gaussian-Wishart
for z = 1:n_components
    L = L - 0.5*post.ns(z)*dim*log(pi);
    L = L - 0.5*dim*log(post.rs(z));
    L = L - post.nus(z)*sum(log(diag(post.Chols(:,:,z))));
    for d = 1:dim
       L = L + gammaln(0.5*(post.nus(z)+1-d));
    end
end


end


function [L] = loglikelihood(dim,num0,r0,nu0,Chol0,num,r,nu,Chol)
L = 0.0;
L = L-0.5*num*dim*log(pi);
L = L-0.5*dim*log(r);
L = L+0.5*dim*log(r0);
L = L-nu*sum(log(diag(Chol)));
L = L+nu0*sum(log(diag(Chol0)));
for d = 1:dim
    L = L+gammaln(0.5*(nu+1-d));
    L = L-gammaln(0.5*(nu0+1-d));
end
end