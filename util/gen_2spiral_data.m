function [ X ] = gen_2spiral_data( N )

%t1 = linspace(0,2*pi,N);
t1 = linspace(0,1.2*pi,N);
%t1 = pi*(1+2*rand(1,N));
x1 = t1.*cos(t1);
x2 = t1.*sin(t1);

%t2 = pi*(1+2*rand(1,N));
t2 = linspace(0,1.2*pi,N);
x21 = -t2.*cos(t2)-1;
x22 = -t2.*sin(t2)+1;

X = [ [x1,x21]', [x2,x22]' ] ;
%X = [ x21', x22' ] ;
%X = [ x1', x2' ] ;

y = [ones(N,1);ones(N,1)*2];
%y = ones(N,2);
%y = [];

plot(X(:,1),X(:,2),'x')

%save('data/spiral2.mat', 'X', 'y', 'labels');
fn = sprintf('data/spiral2_N%d.mat', N );
save(fn, 'X', 'y');