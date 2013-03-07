function p = ag_plot_little_circles(x, y, circle, col, alpha)
%AG_PLOT_LITTLE_CIRCLES Plot circular circles of relative size circle
% Returns handles to all patches plotted

    % aspect is width / height
    %fPos = get(gcf, 'Position');
    % need width, height in data values
    %xl = xlim();
    %yl = ylim();
    w = circle;%*(xl(2)-xl(1));%/fPos(3);
    h = circle;%*(yl(2)-yl(1));%/fPos(4);

    theta = 0:pi/3:2*pi;
    mx = w*sin(theta);
    my = h*cos(theta);
    num = 0;
    for k = 1:max(size(x))
        for f = 1:size(y,2)
            num = num+1;
            p(num) = patch(x(k)+mx, y(k,f)+my, col, 'FaceColor', col, 'FaceAlpha', alpha, 'EdgeColor', 'none');
        end
    end
end
