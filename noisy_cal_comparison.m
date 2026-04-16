%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Uses eyeInHandCalib to produce calibration matrices between cases of 
% clean and noisy data. Allows visual comparison between the output
% matrices for these cases.
%
% Outputs:
% X = calibration matrix with clean data (10 poses used)
% X_noisy = calibration matrix with noisy data (10 poses used)
% X_half = calibration matrix with clean data (5 poses used)
% X_n_half = calibration matrix with noisy data (5 poses used)

clear
clc

%%

% Load clean and noisy quaternion data for the calibration
[q_robot,q_sensor,t_robot,t_sensor] = data_quaternion();
[q_robot_n,q_sensor_n,t_robot_n,t_sensor_n] = data_quaternion_noisy();


% Reformat quaternions to be in the form [q0, q_vec]
for i = 1:size(q_robot,1)
    q_robot(i,:) = [q_robot(i,4) q_robot(i,1:3)];
    q_sensor(i,:) = [q_sensor(i,4) q_sensor(i,1:3)];
    q_robot_n(i,:) = [q_robot_n(i,4) q_robot_n(i,1:3)];
    q_sensor_n(i,:) = [q_sensor_n(i,4) q_sensor_n(i,1:3)];
end

% Perform calibrations
X = eye_in_hand_cal(q_robot,q_sensor,t_robot,t_sensor)
X_noisy = eye_in_hand_cal(q_robot_n,q_sensor_n,t_robot_n,t_sensor_n)

%%

% Repeat clean calibration, with the first half of the data
q_robot_half = q_robot(1:5,:);
q_sensor_half = q_sensor(1:5,:);
t_robot_half = t_robot(1:5,:);
t_sensor_half = t_sensor(1:5,:);

X_half = eye_in_hand_cal(q_robot_half,q_sensor_half,t_robot_half,t_sensor_half)


% Repeat noisy calibration, with the first half of the data
q_robot_n_half = q_robot_n(1:5,:);
q_sensor_n_half = q_sensor_n(1:5,:);
t_robot_n_half = t_robot_n(1:5,:);
t_sensor_n_half = t_sensor_n(1:5,:);

X_n_half = eye_in_hand_cal(q_robot_n_half,q_sensor_n_half,t_robot_n_half,t_sensor_n_half)
