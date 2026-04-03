%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell

% Need reference for least-squares algorithm bc I got that from gemini

% Inputs:
% Ei and Si in quaternion and position vector form
% i must all be the same
% Using quaternion method

function X = eyeInHandCalib(q_robot,q_sensor,t_robot,t_sensor)

    % Initialize M matrix
    M = [];
    R_stack = [];
    t_stack = [];

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
        B = S1*inv(S2);


        %%% Rotation Matrix of X, R_X

        % Extract Rotation matrices of A and B, convert to quaternion form
        R_A = A(1:3,1:3);
        q_A = rotToQuat(R_A); 

        R_B = B(1:3,1:3);
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

        % Form R_stack and t_stack for least-squares problem
        left = R_A - eye(3); % Left side of least-squares problem
        right = R_X*B(1:3,4) - A(1:3,4);

        R_stack = [R_stack; left];
        t_stack = [t_stack; right];

    end

        % SVD of M matrix
        [U,S,V] = svd(M);

        % Quaternion representation of X_R is the last column of V
        q_X = V(:,end);
        R_X = quatToRot(q_X);


        %%% Position Vector of X, t_X 
        t_X = inv(R_stack'*R_stack)*R_stack'*t_stack;


        %%% Assemble Calibration matrix, X
        X = [R_X t_X; zeros(1,3) 1];

end
