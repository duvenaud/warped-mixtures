function [newX,newy] = sampling_data( matfn, newN )

randn('state', 1);
rand('twister', 1); 

load(matfn);
N = size(X,1);
idxs = randsample(N,newN);
newX = X(idxs,:);
newy = y(idxs);

X = newX;
y = newy;
wfn = regexprep(matfn,'\.mat$','');
wfn = sprintf( '%s%d.mat', wfn, newN );
save(wfn,'X','y');