%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell

% PA1, Part 5

clear
clc

% Load file
optpivot_file_name = 'pa1-debug-a-optpivot.txt';
optpivot_file = readmatrix(optpivot_file_name,"NumHeaderLines",1);

% Extract file header
fid = fopen(optpivot_file_name, 'r');
optpivot_header = strip(strsplit(fgetl(fid),","));
fclose(fid);

% extracting variables from txt file header
N = str2double(optpivot_header(1:3));
[Nd, Nh, Nframes] = deal(N(1), N(2), N(3));

% calculating index multiple to split between frames (sum of all points in
% one given frame from all readings)
split_ind = Nd+Nh;

% iterating through all frames to extract and store points
for i = 1:Nframes
    start = ((i-1)*split_ind)+1;

    D_coords{i} = optpivot_file(start:start+Nd-1,:); % Each cell is a frame of data
    H_coords{i} = optpivot_file(start+Nd:start+Nd+Nh-1,:);

end

% Calculate FD here and perform the change of frames?
% i.e. tranform H's into EM coords
