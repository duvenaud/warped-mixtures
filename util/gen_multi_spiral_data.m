function [ X ] = gen_multi_spiral_data( N, K )

X = [];
y = [];

for i = 1:K
    t = linspace(0.3*pi,1.2*pi,N);
    x1 = t.*cos(t)+cos(2*pi*i/K);
    x2 = t.*sin(t)+sin(2*pi*i/K);
    X = [X;[x1',x2']];
end
%X = [ x1', x2' ] ;
%y = ones(N,1);
y = [] ;
plot(X(:,1),X(:,2),'x')

fn = sprintf('data/multi_spiral_N%sK%s.mat',N,K);
save(fn,'X','y');