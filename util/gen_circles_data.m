function [ X ] = gen_circles_data( N, K )

t = linspace(0,2*pi,N)';
X = [];
y = [];
for i = 1:K
    j = i-0.5;
    x1 = j*j*cos(t);
    x2 = j*j*sin(t);
    X = [X;[x1,x2]];
    y = [y;ones(N,1)*i];
end

plot(X(:,1),X(:,2),'x')

fn = sprintf('data/circles_N%dK%d.mat',N,K);
save(fn, 'X', 'y');