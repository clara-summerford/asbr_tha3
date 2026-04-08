%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Uses the least-squares method to perform a pivot calibration using the
% transformation matrices of the probe object as it pivots about a
% calibration post.
%
% Inputs:
% F_mat = a cell array of 4x4 transformation matrices describing the pose
% of the probe captured at different instances of pivoting
%
% Outputs:
% b_tip = the position of the tip of the probe with respect to the local
% probe coordinate frame
% b_post = the position of the dimple in the calibration post with respect
% to the sensor's coordinate frame

function [b_tip, b_post] = pivotCal(F_mat)

    % Initialize stack matrices for least-squares problem
    A_stack = [];
    b_stack = [];

    for k = 1:size(F_mat,2)
        F = F_mat{k};

        % Extract rotation matrices
        R_k = F(1:3,1:3);
        p_k = F(1:3,4);

        A = [R_k -eye(3)];

        % Build stacked matrices
        A_stack = [A_stack;A];
        b_stack = [b_stack;-p_k];
    
    end

    % Compute least-squares solution
    MPP = inv(A_stack'*A_stack)*A_stack'; % Left Moore-Penrose Psuedoinverse
    x = MPP*b_stack;

    % Extract b_tip and b_post
    b_tip = x(1:3);
    b_post = x(4:6);

end