function [X,y] = cancer2mat( fn )

%fn = 'data/tomlins-2006-v2_database.txt';
ymap = containers.Map();
fid = fopen(fn);
X = [];
y = [];
cnt = 1;
while 1;
    % Get a line from the input file
    tline = fgetl(fid);
    % Quit if end of file
    if ~ischar(tline)
        break
    end
    words = regexp(tline,'\s','split');
    %X = [X;str2num(words(2:end))];
    if cnt == 2
        for i = 2:numel(words)
            if ~isKey(ymap,words{i})
                ymap(words{i}) = length(ymap)+1;
            end
            y = [y,ymap(words{i})];
        end
    elseif cnt > 2
        Xi = [];
        for i = 2:numel(words)
            Xi = [Xi,str2num(words{i})];
        end
        X = [X;Xi];
    end
    cnt = cnt+1;
    %dic = [dic,words(2)];
    %dic = [dic,words(3)];
end
X = X';
y = y';
ofn = strrep(fn,'.txt','.mat');
save(ofn,'X','y');