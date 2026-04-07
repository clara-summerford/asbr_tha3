

function [test] = eyeInHandCalibTest(X,q_robot,q_sensor,t_robot,t_sensor)

    A_gt = zeros(4);
    B_gt = zeros(4);

    %%% Calculate Rotation Matrix of X, R_X
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
        B = S1*inv(S2); % Ground truth B matrix

        % Calculate B_test using the Calibration matrix X
        B_test = inv(X)*A*X;

        B-B_test

        %B_gt = (B_gt + B);
        %A_gt = (A_gt + A);

        % Compare 

    end

    % B_gt = B_gt/(size(q_robot,1)-1);
    % A_gt = A_gt/(size(q_robot,1)-1);
    % 
    % % Calculate B_test using the Calibration matrix X
    % B_test2 = inv(X)*A_gt*X;
    % 
    % test = B_gt - B_test2

end