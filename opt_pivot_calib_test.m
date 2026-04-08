%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Compares the output of opt_pivot_calibration, specifically the position of
% the calibration post b_post, to the given values in the THA3 PA1 output
% files.
%
% Inputs:
% file = input file name (string); this function is concerned with files
% ending in 'optpivot.txt'
% gt_file = ground truth file name (string); this function is concerned with files
% ending in 'output1.txt'
% gt_file = ground truth file name (string); this function is concerned with files
% ending in 'output1.txt'
%
% Output: 
% test = a boolean; true if the calculated post position b_post matches the
% ground truth value provided in the output file

function [test] = opt_pivot_calib_test(file,cal_file,gt_file)

    % Perform pivot calibration
    [b_tip,b_post] = opt_pivot_calib(file,cal_file);
    b_post = b_post'; % Transpose

    % Load ground truth from 'output.txt' file
    output_file = readmatrix(gt_file,"NumHeaderLines",1);
    gt_b_post = output_file(2,:); % calbration post location from given output file

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