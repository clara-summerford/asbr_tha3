%% ME384R - ASBR - THA2
% Written by Clara Summerford and Nathan Lovell
%
% Calculates transformation between two point cloud sets. 
%
% Inputs: 
%
% Outputs:

% inputs must be nx3 array of points, where each row corresponds to a point
% and the columns correspond to the xyz values

function [R, p] = PC_registration(frame_a, frame_b)

    pts = length(frame_a);
    
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
    
    [U, ~, V] = svd(H);
    R = V*U';
    
    % check if determinant of R = 1, algorithm fails if not
    if round(det(R),4) ~= 1.0000
        fprintf("Error! Determinant of R does NOT equal 1.")
    else
        fprintf("R is a valid rotation matrix.")
    end

    p = (b_bar' - R*a_bar')';

end

