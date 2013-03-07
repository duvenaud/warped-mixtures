function [] = plot_iwmm_result( hist_params, hist_post, hist_assignments, Y, labels, head )

close all;

addpath('util');
addpath('data');
addpath('gpml/cov');
addpath('gpml/util');

input_dimension = size(Y,2);

if input_dimension == 2
    plot(Y(:,1),Y(:,2),'x');
end
orgaxis = axis;

num_iters = numel(hist_params);
epochs = {num_iters};
%epochs = {1,350,500,1800,3000,5000};
N = size(Y,1);
for i = 1:numel(epochs)
    figure(epochs{i}); clf;
    post = hist_post(epochs{i});
    n_components = size(post.ms,1);
    mix.weights = (post.ns)./sum(post.ns);
    mix.mus = post.ms;
    for z = 1:n_components
        C = chol(inv(post.Chols(:,:,z)'*post.Chols(:,:,z)));
        mix.decomps(:,:,z) = sqrt(post.nus(z))*C;
    end
    %plot_contours( mix );
    plot_contours_one( mix );
    hold on;
    for j = 1:N
        plot( hist_params(epochs{i}).X(j,1), hist_params(epochs{i}).X(j,2),...
            'o',...
            'MarkerEdgeColor', 'k',...
            'MarkerFaceColor', colorbrew(labels(j)));
            %'MarkerFaceColor',
            %colorbrew(find(hist_assignments{epochs{i}}(j,:))));
%            'MarkerFaceColor', 'k');
            %'ok');
    end
    axis off;
    fn = sprintf('figures/%s_x_latent_coordinates_epoch%d.eps',head,epochs{i});
    print( '-depsc', fn );
    hold off;
    %%saveas(gcf,fn,'epsc');
    %%print(gcf, '-depsc', '-painters', fn);
    %%saveas(gcf,'myfig', 'epsc')
    %%continue;
   
    if input_dimension == 2
        draw_gpmapping_mixgauss(hist_params(epochs{i}).X,Y,...
         mix,hist_params(epochs{i}).log_hypers,...
         hist_assignments{epochs{i}},labels,...
         0.02,0.02,100000);
         %0.05,0.03,1000);
        axis( orgaxis );
        axis off;
        fn = sprintf('figures/%s_x3_observed_coordinates_epoch%d.eps',head,epochs{i});
        print( '-depsc', fn );    
    end

end


