function plotlabel( X, Y )

colors = [ 'r', 'b', 'g', 'm', 'p', 'y' ] ;
K = max( Y ) ;
for k=1:K
    plot( X(find(Y==k),1), X(find(Y==k),2), 'o', 'MarkerEdgeColor', colors(k) ) ;
    hold on ;
end
hold off;