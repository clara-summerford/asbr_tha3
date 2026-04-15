%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Uses a correspondence-based method for finding the transformation between 
% two point cloud sets.
%
% Inputs: 
% frame_a, frame_b = an nx3 array of points where columns are xyz values.
% This function assumes that the row indices give the correspondence
% between the sets of points
%
% Outputs: 
% R = rotation matrix corresponding to transformation between the two point
% sets
% p = translation vector corresponding to transformation between the two point
% sets

function [R, p, ref] = PC_registration(frame_a, frame_b)

    % Filter to reject frames of unequal size
    pts = length(frame_a);
    if length(frame_a) ~= length(frame_b)
        fprintf('ERROR: Input point sets are not the same size. \n')
    end
    
    a_bar = (1/pts)*sum(frame_a,1);
    b_bar = (1/pts)*sum(frame_b,1);
    
    H = zeros([3,3,pts]);
    for i = 1:pts
       for a = 1:3 
           for b = 1:3
               a_tild = frame_a(i,a) - a_bar(a); 
               b_tild = frame_b(i,b) - b_bar(b);
               H(a,b,i) = a_tild*b_tild;
           end
       end
    end
    
    H = sum(H,3);
    
    % Calculate R using singular value decomposition
    [U, ~, V] = svd(H);
    R = V*U';
    ref = false;
    
    % check if determinant of R = 1
    if round(det(R),4) ~= 1.0000
        fprintf("WARNING: Determinant of R does NOT equal 1. \n")

        % accounting for R being a reflection: check if a singular value is = 0
        S = svd(H); 
        if S(1) || S(2) || S(3) == 0
            fprintf('Accounting for reflection case... \n')
            V_fix = [V(:,1), V(:,2), -V(:,3)]; % change sign of last column
            R = V_fix*U';
            ref = true;
        else 
            fprintf('ERROR: SVD algorithm is invalid. \n')
        end

    end

    % Output translation vector
    p = (b_bar' - R*a_bar')';

end

