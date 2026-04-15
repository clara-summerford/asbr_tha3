%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Compares the output of opt_pivot_calibration, specifically the position of
% the calibration post b_post, to the given values in the THA3 PA1 output
% files. Only compares the first seven files, i.e., those in which a ground
% truth output file is available.
%
% Output: 
% test = a boolean; true if the calculated post position b_post matches the
% ground truth value provided in the output file

clear
clc
close all

% Load all files
optpivot_files = dir(fullfile('HW3-PA1', '*optpivot.txt'));
calbody_files = dir(fullfile('HW3-PA1', '*calbody.txt'));
output_files = dir(fullfile('HW3-PA1', '*output1.txt'));

file = {optpivot_files.name};
cal_file = {calbody_files.name};
gt_file = {output_files.name};

ref_cnt = zeros(1,length(gt_file));
for i = 1:size(gt_file,2)

% testing
% for i = 1

    % Perform pivot calibration
    [b_tip,b_post,ref_cnt(i)] = opt_pivot_calib(file{i},cal_file{i});
    b_post = b_post'; % Transpose

    % Load ground truth from 'output.txt' file
    output_file = readmatrix(gt_file{i},"NumHeaderLines",1);
    gt_b_post = output_file(2,:); % calbration post location from given output file

    % Optional: Plot the error for each file
    error = b_post - gt_b_post;
    error_norm(i) = norm(error);

    figure
    bar(error_norm)
    title('Optical Pivot Calibration Error (Trials a-g)')
    xticklabels({'a','b','c','d','e','f','g'})
    xlabel('Trial')
    ylabel('Error')
    grid on

    % Compare calculated post position to ground truth
    tol = 1e-2; % Optical tracker much more accurate than EM
    assert(all(abs(b_post - gt_b_post) < tol, 'all'), "ERROR: Calculated post position does not match output file.");

    if all(abs(b_post - gt_b_post) < tol)
        test = true;
        disp('Test PASSED')
    else
        test = false;
    end

end

fprintf('Total frames: \n')
disp(12*ones(1,length(ref_cnt)))
fprintf('Total reflections: \n')
disp(ref_cnt)