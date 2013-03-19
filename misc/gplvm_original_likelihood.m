function [ nll, dnll ] = gplvm_original_likelihood( combined_params, Y, example_params_struct )
    cur_params = rewrap( example_params_struct, combined_params );
    [ nll, dnll_lvm_X, dnll_log_hypers ] = ...
        gplvm_likelihood( cur_params.X, Y, cur_params.log_hypers );
    %checkgrad('gplvm_likelihood', combined_params, 1e-6);
    all_grads_struct.X = dnll_lvm_X;
    all_grads_struct.log_hypers = dnll_log_hypers;
    dnll = unwrap( all_grads_struct );


    %{
    X = cur_params.X;
    [N,D] = size(X);
    if D == 1
       X = [X,ones(N,1)];
    end
    clf;
    cmap = colormap('jet');
    num_bins = size(cmap,1);
    for i = 1:N
        plot( X(i,1), X(i,2), 'x',...
            'Color', cmap(floor((i/N)*(num_bins-1))+1,:));
        hold on;
    end
    drawnow;
    %}
end

