function [ nll, dnll ] = ...
    joint_likelihood_integrate( combined_params, Y, resp, example_params_struct, prior )
    % Computes the joint likelihood of the whole model.
    
    % First, unpack parameters.  
    cur_params = rewrap( example_params_struct, combined_params );

    [ nll_mix, dnll_mix_X ] = ...
        mixture_likelihood_integrate( cur_params.X, resp, prior );
    %checkgrad('mixture_likelihood_integrate', cur_params.X, 1e-6, resp);
    
    [ nll_lvm, dnll_lvm_X, dnll_log_hypers ] = ...
        gplvm_likelihood( cur_params.X, Y, cur_params.log_hypers );
    %checkgrad('gplvm_likelihood', combined_params, 1e-6);

    %[ nll_back, dnll_back_X, dnll_log_hypers_back ] = ...
    %    back_constraint_likelihood( cur_params.X, Y, cur_params.log_hypers );
    nll_back = 0;
    dnll_back_X = 0;
    %checkgrad('back_constraint_likelihood', cur_params.X, 1e-6, Y,
    %cur_params.log_hypers);
    
    nll =  nll_lvm + nll_mix + nll_back;
    
    % Put gradients back into a vector.
    all_grads_struct.X = dnll_lvm_X + dnll_mix_X + dnll_back_X;
    all_grads_struct.log_hypers = dnll_log_hypers;
    dnll = unwrap( all_grads_struct );
end
