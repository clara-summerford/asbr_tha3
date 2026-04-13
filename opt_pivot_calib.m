%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% This script takes experimentally collected pivot calibration data (from
% ASBR THA3 files) and performs a pivot calibration for the optical Probe 
% (the problem formulation is given in THA3 PA1). Input files must be of the 
% form outlined in THA3 PA1. 
%
% Inputs:
% file = input file name (string); this function is concerned with files
% ending in 'empivot.txt'
% cal_file = corresbonding calibration body file name (string); i.e. the 
% files ending in 'calbody.txt'
%
% The output of this script is two vectors, calculated using the least-squares 
% pivot calibration method:
% b_tip = the position of the tip of the optical probe with respect to the local
% probe coordinate frame (defined at the centroid of the probe's optical tracker
% points)
% b_post = the position of the dimple in the calibration post with respect
% to the EM tracker's coordinate frame

function [b_tip,b_post,cnt] = opt_pivot_calib(file, cal_file)

    % Load files
    optpivot_file_name = file;
    optpivot_file = readmatrix(optpivot_file_name,"NumHeaderLines",1);
    calbody_file_name = cal_file; % need this to get d_coords
    calbody_file = readmatrix(calbody_file_name,"NumHeaderLines",1);
    
    % Extract file header
    fid = fopen(optpivot_file_name, 'r');
    optpivot_header = strip(strsplit(fgetl(fid),","));
    fclose(fid);

    fid2 = fopen(calbody_file_name, 'r');
    calbody_header = strip(strsplit(fgetl(fid2),","));
    fclose(fid2);
    
    % extracting variables from txt file header
    N = str2double(optpivot_header(1:3));
    [Nd, Nh, Nframes] = deal(N(1), N(2), N(3));

    N2 = str2double(calbody_header(1:3));
    [Nd, Na, Nc] = deal(N2(1), N2(2), N2(3));
    
    % calculating index multiple to split between frames (sum of all points in
    % one given frame from all readings)
    split_ind = Nd+Nh;
    
    % initializing coordinate sets in a cell array to access individually later
    [D_coords, H_coords] = deal(cell(1,Nframes));

    % iterating through all frames to extract and store points
    for i = 1:Nframes
        start = ((i-1)*split_ind)+1;
    
        D_coords{i} = optpivot_file(start:start+Nd-1,:); % Each cell is a frame of data
        H_coords{i} = optpivot_file(start+Nd:start+Nd+Nh-1,:);
    
    end
    
    % Extract d_coords
    d_coords = calbody_file(1:8,:);
    
    % Calculate FD here and perform the change of frames
    % i.e. tranform H's into EM coords
    for i = 1:Nframes

        % Register d_coords and D_coords to get F_D
        [R_D, p_D, ref] = PC_registration(d_coords,D_coords{i});
        F_D{i} = [R_D, p_D'; zeros(1,3), 1];
    end
    
    figure
    hold on
    view(3)

    % Transform H_coords into EM tracker coordinates using F_D
    for i = 1:Nframes
        for k = 1:Nh
            H = [H_coords{i}(k,:) 1]; % Homogenous representation of first tracker point
            Hd = inv(F_D{i})*H'; % Hd = point H in EM tracker coordinates
            Hd(end) = []; % deleting homogenous representation (1 at end of vector)
            Hd_coords{i}(k,:) = Hd'; % Store coordinates in new cell array
        end
        % disp(Hd_coords{i})

    end
    % scatter3(H_coords{1}(:,1), H_coords{1}(:,2), H_coords{1}(:,3))

    scatter3(Hd_coords{1}(:,1), Hd_coords{1}(:,2), Hd_coords{1}(:,3))
    scatter3(Hd_coords{2}(:,1), Hd_coords{2}(:,2), Hd_coords{2}(:,3))

    
    % Use first frame of data to determine a local "probe" coordinate system
    H0 = sum(Hd_coords{1})/Nh;
    % Centroid of the observed points in frame 1
    h_coords = [Hd_coords{1}(:,1)-H0(1) Hd_coords{1}(:,2)-H0(2) Hd_coords{1}(:,3)-H0(3)] % Translate observed points
    
    % testing
    % h_coords = [H0(1)-Hd_coords{1}(:,1) H0(2)-Hd_coords{1}(:,2) H0(3)-Hd_coords{1}(:,3)] % Translate observed points
    
    scatter3(h_coords(:,1), h_coords(:,2), h_coords(:,2))


    % Registration: calculate transformations between h_coords and Hd_coords for
    % each frame
    cnt = 0;
    for i = 1:Nframes
        % Point cloud registration between h_coords and Hd_coords
        [R,p,ref] = PC_registration(h_coords,Hd_coords{i});

        % testing
        % [R,p,ref] = PC_registration(Hd_coords{i}, h_coords);

        if ref == true
            cnt = cnt + 1;
        end
    
        % Assemble transformation matrix and store in a cell
        F_H{i} = [R p'; zeros(1,3) 1];
    end
    
    % Perform pivot calibration to determine tip and post locations
    [b_tip, b_post] = pivotCal(F_H);

end