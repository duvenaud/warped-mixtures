function [post] = calmix(assignments,prior,params)
%function [post] = calpost(assignments,prior,params)
n_components = size(assignments,2);
for z = 1:n_components
    post.ns(z) = sum(assignments(:,z),1);
    post.alpha(z) = prior.alpha+post.ns(z);
    post.rs(z) = prior.r+post.ns(z);
    post.nus(z) = prior.nu+post.ns(z);
    if post.ns(z) > 0
        Xz = params.X(find(assignments(:,z)==1),:);
        post.ms(z,:) = (prior.r*prior.m+sum(Xz,1))/(prior.r+post.ns(z));
        S = prior.S+Xz'*Xz+prior.r*(prior.m'*prior.m)-post.rs(z)*(post.ms(z,:)'*post.ms(z,:));
        post.Chols(:,:,z) = cholcov(S);
    else
        post.ms(z,:) = prior.m;
        post.Chols(:,:,z) = cholcov(prior.S);
    end
end
mix.weights = (post.ns)./sum(post.ns);
mix.mus = post.ms;
for z = 1:n_components
    C = chol(inv(post.Chols(:,:,z)'*post.Chols(:,:,z)));
    mix.decomps(:,:,z) = sqrt(post.nus(z))*C;
end