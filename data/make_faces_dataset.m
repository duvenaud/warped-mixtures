% Loads images from the faces dataset, downsamples them, and saves them.
%
% David Duvenaud
% Feb 2013

num_faces = 3;          % How many faces to include.
num_frames = 20;        % Use this many frames per face.
downsampled_size = 16;  % shrink images

load umist_cropped.mat

X = NaN(num_faces * num_frames, downsampled_size * downsampled_size);
y = NaN(num_faces * num_frames, 1);

f_ix = 1;
for face = 1:num_faces
    cur_faces = facedat{face};
    for frame = 1:num_frames
        cur_frame = cur_faces(:,:,frame);
        figure(11); clf; imagesc(cur_frame);
        downsampled_frame = imresize( cur_frame, [downsampled_size, downsampled_size]);
        figure(12); clf; imagesc(downsampled_frame);
        X(f_ix,:) = double(downsampled_frame(:));
        y(f_ix) = face;
        %pause;
        f_ix = f_ix + 1;
    end
end

save( 'umist_downsampled.mat', 'X', 'y');
