%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell

% PA1, Part 4

clear
clc

% Load file
empivot_file_name = 'pa1-debug-g-empivot.txt';
empivot_file = readmatrix(empivot_file_name,"NumHeaderLines",1);

% Extract file header
fid = fopen(empivot_file_name, 'r');
empivot_header = strip(strsplit(fgetl(fid),","));
fclose(fid);

% extracting variables from txt file header
N = str2double(empivot_header(1:3));
[Ng, Nframes] = deal(N(1), N(2));

% iterating through all frames to extract and store points
for i = 1:Nframes
    start = ((i-1)*Ng)+1;
    G_coords{i} = empivot_file(start:start+Ng-1,:); % Each cell is a frame of data
end

% Use first frame of data to determine a local "probe" coordinate system
frame1 = G_coords{1};
G0 = sum(frame1)/Ng; % Centroid of the observed points in frame 1
g_coords = [G_coords{1}(:,1)-G0(1) G_coords{1}(:,2)-G0(2) G_coords{1}(:,3)-G0(3)]; % Translate observed points

% Registration: calculate transformations between g_coords and G_coords for
% each frame
for i = 1:Nframes
    % Point cloud registration between g_coords and G_coords
    [R,p] = PC_registration(g_coords,G_coords{i});

    % Assemble transformation matrix and store in a cell
    F_G{i} = [R p'; zeros(1,3) 1];
end

% Perform pivot calibration to determine tip and post locations
[b_tip, b_post] = pivotCal(F_G)