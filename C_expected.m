%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Calculates expected points on calibration marker from EM tracker, denoted
% as C points.
%
% Inputs: Names of text files (as strings) containing calibration marker 
% data as read by the optical and EM trackers, both in the tracker frame 
% (file 2 - "calreadings") and the calibration object frame (file 1 - 
% "calbody").
%
% Outputs: 
% C_est = Cell array containing arrays of expected points where each cell
% corresponds to one frame. 


function [C_exp, C_coords] = C_expected(file1, file2)

    % loading cal body data
    calbody_file_name = file1;
    body_file = readmatrix(calbody_file_name);
    
    % loading cal readings data with multiple frames
    cal_read_file_name = file2;
    cal_file = readmatrix(cal_read_file_name);
        
    % extract file headers
    fid = fopen(cal_read_file_name, 'r');
    cal_header = strip(strsplit(fgetl(fid),","));
    fclose(fid);
    
    fid = fopen(calbody_file_name, 'r');
    body_header = strip(strsplit(fgetl(fid),","));
    fclose(fid);
    
    % extracting variables from txt file header
    N = str2double(cal_header(1:4));
    [Nd, Na, Nc, Nframes] = deal(N(1), N(2), N(3), N(4));
    
    cal_N = str2double(body_header(1:3));
    [cal_Nd, cal_Na, cal_Nc] = deal(cal_N(1), cal_N(2), cal_N(3));
    
    % initializing coordinate sets in a cell array to access individually later
    [D_coords, A_coords, C_coords] = deal(cell(1,Nframes));
    
    % calculating index multiple to split between frames (sum of all points in
    % one given frame from all readings)
    split_ind = Nd+Na+Nc;
    
    % iterating through all frames to extract and store points
    for i = 1:Nframes
        % fprintf('Iteration %d', i)
        start = ((i-1)*split_ind)+1;
    
        D_coords{i} = cal_file(start:start+Nd-1,:);
        A_coords{i} = cal_file(start+Nd:start+Nd+Na-1,:);
        C_coords{i} = cal_file(start+Nd+Na:start+Nd+Na+Nc-1, :);
    end
    
    cal_d_coords = body_file(1:cal_Nd,:);
    cal_a_coords = body_file(cal_Nd+1:cal_Nd+cal_Na,:);
    cal_c_coords = body_file(cal_Nd+cal_Na+1:end, :);
    
    % looping through all frames and calculating translations
    [R_D, p_D, R_A, p_A] = deal(cell(1, Nframes));
    frame_d = cal_d_coords;
    frame_a = cal_a_coords;
    
    C_exp = [];
    for i = 1:Nframes
    
        frame_D = D_coords{i};
        % check order??????
        [R_D{i}, p_D{i}] = PC_registration(frame_d, frame_D);
        
        frame_A = A_coords{i};
        [R_A{i}, p_A{i}] = PC_registration(frame_a, frame_A);
    
        F_D = [R_D{i}, p_D{i}'; zeros(1,3), 1];
        F_A = [R_A{i}, p_A{i}'; zeros(1,3), 1];
    
        % empty C_est matrix for each frame
        C_est_temp = zeros(size(cal_c_coords));
    
        for j = 1:length(cal_c_coords)
    
            % need homogenous vector for 4x4 transformation matrix
            ci_hom = [cal_c_coords(j,:), 1]';
            C = (inv(F_D)*F_A*ci_hom)';
    
            % normalizing by the last value in the vector to return a
            % homogenous vector representation (last element should = 1)
            C_est_temp(j,:) = C(1:3)/C(4);
        end

        C_exp = [C_exp; C_est_temp];
    
    end

end % function

