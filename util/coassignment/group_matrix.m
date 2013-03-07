function sorted_eca = group_matrix( eca, assignment )

% Sorts a matrix such that the blocks all have the same assignment.

N = size(assignment, 1);

indices = NaN(N,1);

sorted_eca = NaN(size(eca));



for n = 1:N
    indices(n) = find( assignment( n, :));
end

[ignore, sort_perm] = sort(indices);

for n1 = 1:N
    for n2 = 1:N
        sorted_eca(n1, n2) = eca(sort_perm(n1), sort_perm(n2));
    end
end

if 0

unique_indices = unique(indices);
num_groups = numel(unique_indices);

done = 0;
for g = 1:num_groups
    cur_ixs = find(indices == unique_indices(g));
    cur_count = numel(cur_ixs);
    
    for d1 = 1:cur_count
        for d2 = 1:cur_count
            sorted_eca(done + d1, done + d2) = eca(cur_ixs(d1), cur_ixs(d2));
        end
    end
    done = done + cur_count;
end
end