function [ X ] = gen_spiral_data( N )

t = linspace(0,1.2*pi,N);
%t = pi*(1+1.5*rand(1,N));
x1 = t.*cos(t);
x2 = t.*sin(t);
X = [ x1', x2' ] ;
%y = ones(N,1);
y = [] ;
plot(X(:,1),X(:,2),'x')

save('data/spiral.mat', 'X', 'y');