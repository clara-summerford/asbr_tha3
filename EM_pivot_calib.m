%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% This script takes experimentally collected pivot calibration data (from
% ASBR THA3 files) and performs a pivot calibration for the EM Probe (the
% problem formulation is given in THA3 PA1). Input files must be of the 
% form outlined in THA3 PA1. 
%
% Inputs:
% file = input file name (string); this function is concerned with files
% ending in 'empivot.txt'
%
% The output of this script is two vectors, calculated using the least-squares 
% pivot calibration method:
% b_tip = the position of the tip of the EM probe with respect to the local
% probe coordinate frame (defined at the centroid of the probe's EM tracker
% points)
% b_post = the position of the dimple in the calibration post with respect
% to the EM tracker's coordinate frame

function [b_tip,b_post,cnt] = EM_pivot_calib(file)

    % Load file
    empivot_file_name = file;
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
    G0 = sum(G_coords{1})/Ng; % Centroid of the observed points in frame 1
    g_coords = [G_coords{1}(:,1)-G0(1) G_coords{1}(:,2)-G0(2) G_coords{1}(:,3)-G0(3)]; % Translate observed points
    
    % Registration: calculate transformations between g_coords and G_coords for
    % each frame
    cnt = 0;
    for i = 1:Nframes
        % Point cloud registration between g_coords and G_coords
        % disp('G_cords')
        % disp(i)
        [R,p,ref] = PC_registration(g_coords,G_coords{i});
        if ref == true
            cnt = cnt + 1;
        end
    
        % Assemble transformation matrix and store in a cell
        F_G{i} = [R p'; zeros(1,3) 1];
    end


    % Perform pivot calibration to determine tip and post locations
    [b_tip, b_post] = pivotCal(F_G);

    % plotting pivot markers for debugging
    figure
    scatter3()

end