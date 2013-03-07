function [X,y] = scale2mat( fn, N, D )

if nargin == 3
    X = zeros(N,D);
end
    
fid = fopen(fn);
cnt = 1;
tline = fgetl(fid);
while ischar(tline)
    tline = regexprep(tline,'\s*$','');
    r = regexp(tline,'\s','split');
    label = str2double(r(1));
    y(cnt) = label;
    for i = 2:numel(r)
        s = regexp(r(i),':','split');
        idx = str2double(s{1}(1));
        val = str2double(s{1}(2));
        X(cnt,idx) = val;
    end
    cnt = cnt+1;
    tline = fgetl(fid);
end

[N,D] = size(X);
if min(y) == 0
    y = y+1;
end
K = max(y);
fprintf( 'N=%d, D=%d, K=%d\n',N,D,K);
wfn = regexprep(fn,'\..*$','.mat');
save(wfn,'X','y');
