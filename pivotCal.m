
% Least-squares method to solve for tool lip position w.r.t. local tool frame
% and pivot point location w.r.t. tracker

% Assumes F_mat is a bunch of transf matrices stacked vertically

function [b_tip, b_post] = pivotCal(F_mat)

    % Initialize stack matrices for least-squares problem
    A_stack = [];
    b_stack = [];

    for k = 1:4:size(F_mat,1)
        % Extract rotation matrices
        R_k = F_mat(k:(k+2),1:3);
        p_k = F_mat(k:(k+2),4);

        A = [R_k -eye(3)];

        % Build stacked matrices
        A_stack = [A_stack;A];
        b_stack = [b_stack;p_k];
    
    end

    % Compute least-squares solution
    MPP = inv(A_stack'*A_stack)*A_stack'; % Left Moore-Penrose Psuedoinverse
    x = MPP*b_stack;

    % Extract b_tip and b_post
    b_tip = x(1:3);
    b_post = x(4:6);

end