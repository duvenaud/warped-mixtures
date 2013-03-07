function eca = average_coassignment( assignments )
%
% Computes the average coassignment of a set of variables, given
% a cell array containing sample assignments.
%
% David Duvenaud
% June 2012

n_samples = numel(assignments);
n_data = size(assignments{1}, 1);

eca = zeros( n_data, n_data );

%sample_num = 1000;
%sample_start = n_samples-sample_num+1;
%for a_ix = sample_start:n_samples
for a_ix = 1:n_samples
    cur_assignments = assignments{a_ix};
    for n1_ix = 1:n_data
        for n2_ix = 1:n_data
            if find(cur_assignments(n1_ix, :)) == ...
               find(cur_assignments(n2_ix, :))
                eca(n1_ix, n2_ix) = eca(n1_ix, n2_ix) + 1;
            end
        end
    end
end

eca = eca ./ n_samples;
               