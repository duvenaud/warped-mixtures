function [params, nll, arate] = hmc(likefunc, x, options, labels, varargin)     
% Hamiltonian Monte Carlo
%
% David Duvenaud
% Tomoharu Iwata
%
% April 2012
%
% likefunc returns nll, dnll
%
% options.Tau is the number of leapfrog steps. 
% options.epsilon is step length

%{
if options.isPlot == 1
    assignments = varargin{end-2};
    params = varargin{end-1};
    prior = varargin{end};
    mix = calmix(assignments,prior,params);
end
%}

arate = 0; %acceptance rate
L = options.num_iters;

[E, g] = likefunc( x, varargin{:});

for l = 1:L
    p = randn( size( x ) );
    H = p' * p / 2 + E;
    
    xnew = x; gnew = g;
 
    cur_tau = randi(options.Tau);
    cur_eps = rand * options.epsilon;
    %cur_tau = options.Tau;
    %cur_eps = options.epsilon;
    for tau = 1:cur_tau
        p = p - cur_eps * gnew / 2;
        xnew = xnew + cur_eps * p;
        [ignore, gnew] = likefunc( xnew, varargin{:}); 
        
        %{
        % Plot current mixture
        if options.isPlot == 1
            cur_params = rewrap( varargin{end-1}, xnew );
            draw_latent_representation( cur_params.X,mix,varargin{2},labels );
            %pause(0.001);
        end
        %}
        
        p = p - cur_eps * gnew / 2;
    end
    
    [Enew, ignore] = likefunc( xnew, varargin{:});    
    Hnew = p' * p / 2 + Enew;
    dh = Hnew - H;
    
    if dh < 0
        accept = 1;
        fprintf('a');
    else
        if rand() < exp(-dh)
            accept = 1;
            fprintf('A');
        else
            accept = 0;
            fprintf('r');
        end
    end
    
    if accept
        g = gnew;
        x = xnew;
        E = Enew;
        arate = arate+1;
    end
end
 
arate = arate/L;
params = x;
nll = E;
