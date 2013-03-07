function [ X ] = gen_3d2spiral_data( N )

%t1 = linspace(0,2*pi,N);
t1 = linspace(0,1.2*pi,N);
%t1 = pi*(1+2*rand(1,N));
x11 = t1.*cos(t1);
x12 = t1.*sin(t1);

%t2 = pi*(1+2*rand(1,N));
t2 = linspace(0,1.2*pi,N);
x21 = -t2.*cos(t2)-1;
x22 = -t2.*sin(t2)+1;

x13 = zeros(1,numel(x11));
x23 = zeros(1,numel(x11));

X = [x11',x12',x13'];
for i = 1:numel(x21)
    z = [-0.3:0.1:0.3]';
    X = [X;[repmat([x21(i),x22(i)],numel(z),1),z]];
end
%X = [ x21', x22' ] ;
%X = [ x1', x2' ] ;

%y = [ones(N,1);ones(N,1)*2];
%y = ones(N,2);
y = [];

plot3(X(:,1),X(:,2),X(:,3),'x');
axis([-4 4 -4 4 -4 4]);

%save('data/spiral2.mat', 'X', 'y', 'labels');
save('data/spiral2_3d.mat', 'X', 'y');