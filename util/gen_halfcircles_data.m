function [ X ] = gen_halfcircles_data( N, K )

t = linspace(0,pi,N)';
X = [];
y = [];
for i = 1:K
    x1 = i+cos(t)+i*0.5-3;
    x2 = ((-1)^(i+1))*sin(t)+((-1)^i*0.1);
    X = [X;[x1,x2]];
    y = [y;ones(N,1)*i];
end

plot(X(:,1),X(:,2),'x')

fn = sprintf('data/halfcircles_N%dK%d.mat',N,K);
save(fn, 'X', 'y');