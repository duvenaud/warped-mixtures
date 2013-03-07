% Loads images from the faces dataset, downsamples them, and saves them.
%
% David Duvenaud
% Feb 2013

num_faces = 2;          % How many faces to include.
%num_frames = 20;        % Use this many frames per face.
downsampled_size = 32;  % shrink images

load umist_cropped.mat

X = NaN(num_faces * 1, downsampled_size * downsampled_size);
y = NaN(num_faces * 1, 1);

f_ix = 1;
start_idx = 3;
for face = start_idx:start_idx+num_faces-1
    cur_faces = facedat{face};
    for frame = 1:size(cur_faces,3)
        cur_frame = cur_faces(:,:,frame);
        figure(11); clf; imagesc(cur_frame);
        downsampled_frame = imresize( cur_frame, [downsampled_size, downsampled_size]);
        figure(12); clf; imagesc(downsampled_frame);
        X(f_ix,:) = double(downsampled_frame(:));
        y(f_ix) = face;
        %pause(0.01);
        f_ix = f_ix + 1;
    end
end

save( 'data/umist_downsampled3.mat', 'X', 'y');
