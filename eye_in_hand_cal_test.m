%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Test function that validates the Eye-In-Hand Calibration method utilized
% in the eyeInHandCalib function. This function uses a ground truth
% calibration matrix, X_gt, to calculate a set of test matrices B_test.
% These B_tests are then used to solve the AX=XB problem for the matrix
% X_test. Finally, the function compares X_gt and X_test for equality.
% The passing of this test function indicates that the AX=XB solver in
% eyeInHandCalib is working correctly.
%
% Inputs:
% X_gt = Arbitrary transformation matrix describing a hypothetical
% configuration of a sensor with respect to the end-effector of a robot.
% q_robot = Orientation of robot end_effector with respect to the base
% frame, in quaternion form [q0, q_vec] (scalar value first!)
% q_sensor = Orientation of calibration object with respect to the sensor
% frame, in quaternion form [q0, q_vec] (scalar value first!)
% t_robot = Position of robot end-effector with respect to the base frame
% t_robot = Position of calibration object with respect to the sensor frame
% 
% Outputs:
% test = a boolean; true if the calculated calibration matrix X_test matches 
% the ground truth matrix X_gt


function [test] = eye_in_hand_cal_test(X_gt,q_robot,q_sensor,t_robot,t_sensor)

    % Example: random calibration matrix for verifying AX=XB algorithm
    % X_gt = [1 0 0 1; 0 1 0 1; 0 0 1 1; 0 0 0 1]; % Ground truth


    %%% Plot calibration error converging with more poses
    for i = 2:(size(q_robot,1))
        Xcell{i-1} = eyeInHandCalib(q_robot(1:i,:),q_sensor(1:i,:),t_robot(1:i,:),t_sensor(1:i,:));
    end

    for i = 1:(size(Xcell,2)-1)
        error = Xcell{i+1}(1:3,4) - Xcell{i}(1:3,4);
        error_norm(i) = norm(error);
    end

    x = 3:10; % x-axis is number of poses used to compute X

    semilogy(x,error_norm,'--ro')
    legend('Calibration Error (translation)')
    title('Convergence of Calibration Error')
    xlabel('Number of Poses Used in Calibration') %
    grid on 
    

    %%% Calculate Rotation Matrix of X, R_X 

    % Initialization
    M = [];

    for i = 2:(size(q_robot,1))
        % Convert quaternions to rotation matrices
        R1_robot = quatToRot(q_robot(i-1,:)); % Previous robot orientation
        R1_sensor = quatToRot(q_sensor(i-1,:)); % Previous sensor orientation
        R2_robot = quatToRot(q_robot(i,:)); % Current sensor orientation
        R2_sensor = quatToRot(q_sensor(i,:)); % Current sensor orientation

        % Build E_i and S_i (transformation matrices)?
        E1 = [R1_robot t_robot(i-1,:)'; zeros(1,3) 1];
        S1 = [R1_sensor t_sensor(i-1,:)'; zeros(1,3) 1];
        E2 = [R2_robot t_robot(i,:)'; zeros(1,3) 1];
        S2 = [R2_sensor t_sensor(i,:)'; zeros(1,3) 1];

        % Calculate A and B matrices
        A = inv(E1)*E2;
        B_test = inv(X_gt)*A*X_gt; % Calculate B_test using X_gt

        % Extract Rotation matrices of A and B, convert to quaternion form
        R_A = A(1:3,1:3);
        q_A = rotToQuat(R_A); 

        R_B = B_test(1:3,1:3);
        q_B = rotToQuat(R_B);

        % Split quaternions into scalar and vector parts
        s_A = q_A(1);
        v_A = q_A(2:4); % check the dimensions of this

        s_B = q_B(1);
        v_B = q_B(2:4); % check the dimensions of this

        % Form M matrix
        M11 = s_A - s_B;
        M12 = -(v_A - v_B)';
        M21 = v_A - v_B;
        M22 = (s_A - s_B)*eye(3) + vec2SkewSym(v_A + v_B);

        M_i = [M11 M12; M21 M22];
        M = [M;M_i];

    end

    % SVD of M matrix
    [U,S,V] = svd(M);

    % Quaternion representation of X_R is the last column of V
    q_X = V(:,end);
    R_X = quatToRot(q_X);


    %%% Calculate position Vector of X, t_X 

    % Initialization
    R_stack = [];
    t_stack = [];

    % Re-run the loop 
    for i = 2:(size(q_robot,1))
        % Convert quaternions to rotation matrices
        R1_robot = quatToRot(q_robot(i-1,:)); % Previous robot orientation
        R1_sensor = quatToRot(q_sensor(i-1,:)); % Previous sensor orientation
        R2_robot = quatToRot(q_robot(i,:)); % Current sensor orientation
        R2_sensor = quatToRot(q_sensor(i,:)); % Current sensor orientation

        % Build E_i and S_i (transformation matrices)?
        E1 = [R1_robot t_robot(i-1,:)'; zeros(1,3) 1];
        S1 = [R1_sensor t_sensor(i-1,:)'; zeros(1,3) 1];
        E2 = [R2_robot t_robot(i,:)'; zeros(1,3) 1];
        S2 = [R2_sensor t_sensor(i,:)'; zeros(1,3) 1];

         % Calculate A and B_test matrices
        A = inv(E1)*E2;
        B_test = inv(X_gt)*A*X_gt;

        % Extract Rotation matrix of A
        R_A = A(1:3,1:3);

        % Form R_stack and t_stack for least-squares problem
        left = R_A - eye(3); % Left side of least-squares problem
        right = R_X*B_test(1:3,4) - A(1:3,4);

        R_stack = [R_stack; left];
        t_stack = [t_stack; right];

    end

    % Position vector of sensor w.r.t. hand
    t_X = inv(R_stack'*R_stack)*R_stack'*t_stack; % Using MP Psuedoinverse


    %%% Assemble Calibration matrix caulculated with our calibration
    %%% method, i.e., X_test
    X_test = [R_X t_X; zeros(1,3) 1];


    % Compare X_test with X_gt
    tol = 1e-4; % Arbitrary tolerance
    assert(all(abs(X_gt - X_test) < tol, 'all'), "ERROR: Calculated calibration matrix does not match the ground truth.");

    if all(abs(X_gt - X_test) < tol)
        test = true;
        disp('Test PASSED')
    else
        test = false;
    end

end